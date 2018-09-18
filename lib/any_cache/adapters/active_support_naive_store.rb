# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class ActiveSupportNaiveStore < Delegator
    require_relative 'active_support_naive_store/operation'
    require_relative 'active_support_naive_store/increment'
    require_relative 'active_support_naive_store/decrement'
    require_relative 'active_support_naive_store/expire'
    require_relative 'active_support_naive_store/persist'

    # @param driver [Object]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(driver)
      super
      @lock = Concurrent::ReentrantReadWriteLock.new
      @incr_operation = self.class::Increment.new(driver)
      @decr_operation = self.class::Decrement.new(driver)
      @expr_operation = self.class::Expire.new(driver)
      @pers_operation = self.class::Persist.new(driver)
    end

    # @param key [String]
    # @param options [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def read(key, **options)
      lock.with_read_lock { super }
    end

    # @param keys [Array<String>]
    # @param options [Hash]
    # @return [Hash]
    #
    # @api private
    # @since 0.3.0
    def read_multi(*keys, **options)
      lock.with_read_lock do
        super.tap do |res|
          res.merge!(Hash[(keys - res.keys).zip(Operation::READ_MULTI_EMPTY_KEYS_SET)])
        end
      end
    end

    # @param key [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def delete(key, **options)
      lock.with_write_lock { super }
    end

    # @param pattern [Object]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def delete_matched(pattern, **options)
      lock.with_write_lock { super }
    end

    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def clear(**options)
      lock.with_write_lock { super }
    end

    # @param key [String]
    # @param value [Object]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def write(key, value, **options)
      lock.with_write_lock do
        expires_in = options.fetch(:expires_in, self.class::Operation::NO_EXPIRATION_TTL)

        super(key, value, expires_in: expires_in)
      end
    end

    # @param entries [Hash]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def write_multi(entries, **options)
      lock.with_write_lock do
        expires_in = self.class::Operation::NO_EXPIRATION_TTL

        super(entries, expires_in: expires_in)
      end
    end

    # @param key [String]
    # @param fallback [Proc]
    # @option expires_in [Integer]
    # @option force [Boolean, Proc]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def fetch(key, **options, &fallback)
      lock.with_write_lock do
        force_rewrite = options.fetch(:force, false)
        force_rewrite = force_rewrite.call(key) if force_rewrite.respond_to?(:call)
        expires_in    = options.fetch(:expires_in, self.class::Operation::NO_EXPIRATION_TTL)

        super(key, force: force_rewrite, expires_in: expires_in, &fallback)
      end
    end

    # @param keys [Array<String>]
    # @param fallback [Proc]
    # @option force [Boolean, Proc]
    # @option expires_in [Integer]
    # @return [Hash]
    #
    # @api private
    # @since 0.3.0
    def fetch_multi(*keys, **options, &fallback)
      lock.with_write_lock do
        force_rewrite = options.fetch(:force, false)
        expires_in    = options.fetch(:expires_in, self.class::Operation::NO_EXPIRATION_TTL)

        # NOTE:
        #   use own #fetch_multi implementation cuz original #fetch_multi
        #   does not support :force option
        keys.each_with_object({}) do |key, dataset|
          force = force_rewrite.respond_to?(:call) ? force_rewrite.call(key) : force_rewrite
          dataset[key] = driver.fetch(key, force: force, expires_in: expires_in, &fallback)
        end
      end
    end

    # @param key [String]
    # @param amount [Integer, Float]
    # @option expires_in [NilClass, Integer]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def increment(key, amount = self.class::Increment::DEFAULT_AMOUNT, **options)
      lock.with_write_lock do
        expires_in = options.fetch(:expires_in, self.class::Operation::NO_EXPIRATION_TTL)

        incr_operation.call(key, amount, expires_in: expires_in)
      end
    end

    # @param key [String]
    # @param amount [Integer, Float]
    # @option expires_in [NilClass, Integer]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def decrement(key, amount = self.class::Decrement::DEFAULT_AMOUNT, **options)
      lock.with_write_lock do
        expires_in = options.fetch(:expires_in, self.class::Operation::NO_EXPIRATION_TTL)

        decr_operation.call(key, amount, expires_in: expires_in)
      end
    end

    # @param key [String]
    # @option expires_in [NilClass, Integer]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def expire(key, expires_in: self.class::Operation::DEAD_TTL)
      lock.with_write_lock { expr_operation.call(key, expires_in: expires_in) }
    end

    # @param key [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def persist(key, **options)
      lock.with_write_lock { pers_operation.call(key) }
    end

    # @param key [String]
    # @param options [Hash]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def exist?(key, **options)
      lock.with_read_lock { super }
    end

    private

    # @return [Concurrent::ReentrantReadWriteLock]
    #
    # @api private
    # @since 0.1.0
    attr_reader :lock

    # @return [Operation::Increment]
    #
    # @api private
    # @since 0.1.0
    attr_reader :incr_operation

    # @return [Operation::Decrement]
    #
    # @api private
    # @since 0.1.0
    attr_reader :decr_operation

    # @return [Operation::Expire]
    #
    # @api private
    # @since 0.1.0
    attr_reader :expr_operation

    # @return [Operation::Persist]
    #
    # @api private
    # @since 0.1.0
    attr_reader :pers_operation
  end
end
