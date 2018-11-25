# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.2.0
  class ActiveSupportMemCacheStore < Basic
    # NOTE: think about locks (Concurrent::ReentrantReadWriteLock)

    class << self
      # @param driver [Object]
      # @retunr [Boolean]
      #
      # @api private
      # @since 0.2.0
      def supported_driver?(driver)
        AnyCache::Drivers::ActiveSupportMemCacheStore.supported_source?(driver)
      end
    end

    # @return [Array]
    #
    # @api private
    # @since 0.3.0
    READ_MULTI_EMPTY_KEYS_SET = [].freeze

    # @return [NilClass]
    #
    # @api private
    # @since 0.2.0
    NO_EXPIRATION_TTL = nil

    # @return [Integer]
    #
    # @api private
    # @since 0.2.0
    DEAD_TTL = 0

    # @return [Integer]
    #
    # @api private
    # @since 0.2.0
    DEFAULT_INCR_DECR_AMOUNT = 1

    # @return [Integer]
    #
    # @api private
    # @since 0.2.0
    INITIAL_DECREMNETED_VALUE = 0

    # @since 0.2.0
    def_delegators :driver, :delete, :clear

    # @param key [String]
    # @param options [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def read(key, **options)
      raw = options.fetch(:raw, true)

      driver.read(key, raw: raw)
    end

    # @param keys [Array<String>]
    # @param options [Hash]
    # @return [Hash]
    #
    # @api private
    # @since 0.3.0
    def read_multi(*keys, **options)
      raw = options.fetch(:raw, true)

      driver.read_multi(*keys, raw: raw).tap do |entries|
        entries.merge!(Hash[(keys - entries.keys).zip(READ_MULTI_EMPTY_KEYS_SET)])
      end
    end

    # @param key [String]
    # @param value [Object]
    # @option expires_in [NilClass, Integer] Time in seconds
    # @return [void]
    #
    # @api private
    # @sicne 0.2.0
    def write(key, value, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)
      raw = options.fetch(:raw, true)

      driver.write(key, value, expires_in: expires_in, raw: raw)
    end

    # @param entries [Hash]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def write_multi(entries, **options)
      raw = options.fetch(:raw, true)

      driver.write_multi(entries, expires_in: NO_EXPIRATION_TTL, raw: raw)
    end

    # @param key [String]
    # @option expires_in [Integer]
    # @option force [Boolean, Proc]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def fetch(key, **options, &fallback)
      force_rewrite = options.fetch(:force, false)
      force_rewrite = force_rewrite.call(key) if force_rewrite.respond_to?(:call)
      expires_in    = options.fetch(:expires_in, NO_EXPIRATION_TTL)

      driver.fetch(key, force: force_rewrite, expires_in: expires_in, &fallback)
    end

    # @param keys [Array<String>]
    # @param options [Hash]
    # @param fallback [Proc]
    # @return [Hash]
    #
    # @api private
    # @since 0.3.0
    def fetch_multi(*keys, **options, &fallback)
      keys.each_with_object({}) do |key, dataset|
        dataset[key] = fetch(key, **options, &fallback)
      end
    end

    # @param pattern [String, Regexp]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def delete_matched(pattern, **options)
      # TODO: make it real >:]
    end

    # @param key [String]
    # @param amount [Integer]
    # @options expires_in [Integer]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.2.0
    def increment(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)

      unless exist?(key)
        write(key, amount, expires_in: expires_in) && amount
      else
        driver.increment(key, amount).tap do
          expire(key, expires_in: expires_in) if expires_in
        end
      end
    end

    # @param key [String]
    # @param amount [Integer]
    # @option expires_in [Integer]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.2.0
    def decrement(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)

      unless exist?(key)
        # NOTE: Dalli::Client can't decrement:
        #   - non-raw values;
        #   - values lower than zero;
        #   - empty entries;
        write(key, INITIAL_DECREMNETED_VALUE, expires_in: expires_in) && INITIAL_DECREMNETED_VALUE
      else
        driver.decrement(key, amount).tap do
          expire(key, expires_in: expires_in) if expires_in
        end
      end
    end

    # @param key [String]
    # @option expires_in [Integer]
    # @return [void]
    #
    # @api private
    # @since 0.2.0
    def expire(key, expires_in: DEAD_TTL)
      read(key).tap do |value|
        is_alive = expires_in ? expires_in.positive? : false
        is_alive ? write(key, value, expires_in: expires_in) : delete(key)
      end
    end

    # @param key [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @sicne 0.2.0
    def persist(key, **options)
      read(key).tap { |value| write(key, value) }
    end

    # @param key [String]
    # @param options [Hash]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def exist?(key, **options)
      driver.exist?(key)
    end

    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.4.0
    def cleanup(**options)
      # NOTE: manual removing is not supported (memcached doing it by itself)
    end
  end
end
