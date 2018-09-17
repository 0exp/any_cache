# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class Dalli < Basic
    class << self
      # @param driver [Object]
      # @return [Boolean]
      #
      # @api private
      # @since 0.1.0
      def supported_driver?(driver)
        AnyCache::Drivers::Dalli.supported_source?(driver)
      end
    end

    # @return [Integer]
    #
    # @api private
    # @since 0.1.0
    NO_EXPIRATION_TTL = 0

    # @return [NilClass]
    #
    # @api private
    # @since 0.1.0
    DEAD_TTL = nil

    # @return [Integer]
    #
    # @api private
    # @since 0.1.0
    DEFAULT_INCR_DECR_AMOUNT = 1

    # @return [Integer]
    #
    # @api private
    # @since 0.1.0
    MIN_DECRESEAD_VAL = 0

    # @return [Array]
    #
    # @api private
    # @since 0.3.0
    READ_MULTI_EMPTY_KEYS_SET = [].freeze

    # @since 0.1.0
    def_delegators :driver,
                   :get,
                   :get_multi,
                   :set,
                   :incr,
                   :decr,
                   :multi,
                   :touch,
                   :flush

    # @param key [String]
    # @param options [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def read(key, **options)
      get(key)
    end

    # @param keys [Array<String>]
    # @param options [Hash]
    # @return [Hash]
    #
    # @api private
    # @since 0.3.0
    def read_multi(*keys, **options)
      get_multi(*keys).tap do |res|
        res.merge!(Hash[(keys - res.keys).zip(READ_MULTI_EMPTY_KEYS_SET)])
      end
    end

    # @param key [String]
    # @param value [Object]
    # @option expires_in [Integer]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def write(key, value, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)
      raw = options.fetch(:raw, true)

      set(key, value, expires_in, raw: raw)
    end

    # @param entries [Hash]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def write_multi(entries, **options)
      raw = options.fetch(:raw, true)

      entries.each_pair { |key, value| write(key, value, raw: raw) }
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
      force_rewrite = options.fetch(:force, false)
      force_rewrite = force_rewrite.call(key) if force_rewrite.respond_to?(:call)

      # NOTE: can conflict with :cache_nils Dalli::Client's config
      read(key).tap { |value| return value if value } unless force_rewrite

      fallback.call(key).tap { |value| write(key, value, **options) } if block_given?
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
      # TODO: think about multi-thread approach
      keys.each_with_object({}) do |key, dataset|
        dataset[key] = fetch(key, **options, &fallback)
      end
    end

    # @param key [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def delete(key, **options)
      driver.delete(key)
    end

    # @param pattern [Object]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def delete_matched(pattern, **options)
      # NOTE: unsupported
    end

    # @param key [String]
    # @param amount [Integer]
    # @option expires_in [NilClass, Integer]
    # @return [NilClass, Integer]
    #
    # @api private
    # @since 0.1.0
    def increment(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)

      # TODO: think about #cas and Concurrent::ReentrantReadWriteLock
      incr(key, amount, expires_in, amount).tap do |new_amount|
        touch(key, expires_in) if new_amount && expires_in.positive?
      end
    end

    # @param key [String]
    # @param amount [Integer]
    # @option expires_in [NilClass, Integer]
    # @return [NilClass, Integer]
    #
    # @api private
    # @since 0.1.0
    def decrement(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)

      # TODO: think about #cas and Concurrent::ReentrantReadWriteLock
      decr(key, amount, expires_in, MIN_DECRESEAD_VAL).tap do |new_amount|
        touch(key, expires_in) if new_amount && expires_in.positive?
      end
    end

    # @param key [String]
    # @option expires_in [Integer]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def expire(key, expires_in: DEAD_TTL)
      is_alive = expires_in ? expires_in.positive? : false
      is_alive ? touch(key, expires_in) : driver.delete(key)
    end

    # @param key [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def persist(key, **options)
      touch(key, NO_EXPIRATION_TTL)
    end

    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def clear(**options)
      flush(0) # NOTE: 0 is a flush delay
    end

    # @param key [String]
    # @param options [Hash]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def exist?(key, **options)
      !get(key).nil? # NOTE: can conflict with :cache_nils Dalli::Client's config
    end
  end
end
