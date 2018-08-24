# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class ActiveSupportNaiveStore < Delegator
    require_relative 'active_support_naive_store/operation'
    require_relative 'active_support_naive_store/increment'
    require_relative 'active_support_naive_store/decrement'
    require_relative 'active_support_naive_store/expire'

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

    # @param key [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def delete(key, **options)
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
    def expire(key, expires_in: self.class::Operation::NO_EXPIRATION_TTL)
      lock.with_write_lock { expr_operation.call(key, expires_in: expires_in) }
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

    # @return [Operation::ReExpire]
    #
    # @api private
    # @since 0.1.0
    attr_reader :expr_operation
  end
end
