# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class ActiveSupportRedisCacheStore < Basic
    # TODO: think about locks

    class << self
      # @param driver [Object]
      # @return [Boolean]
      #
      # @api private
      # @since 0.1.0
      def supported_driver?(driver)
        defined?(::Redis) &&
        defined?(::ActiveSupport::Cache::RedisCacheStore) &&
        driver.is_a?(::ActiveSupport::Cache::RedisCacheStore)
      end
    end

    # @since 0.1.0
    def_delegators :driver, :delete, :clear

    # @return [NilClass]
    #
    # @api private
    # @since 0.1.0
    NO_EXPIRATION_TTL = nil

    # @return [Integer]
    #
    # @api private
    # @since 0.1.0
    DEAD_TTL = 0

    # @return [Integer]
    #
    # @api private
    # @since 0.1.0
    DEFAULT_INCR_DECR_AMOUNT = 1

    # @param key
    # @param options [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def read(key, **options)
      driver.read(key, raw: true)
    end

    # @param key [String]
    # @param value [Object]
    # @option expires_in [NilClass, Integer] Time in seconds
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def write(key, value, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)

      driver.write(key, value, expires_in: expires_in, raw: true)
    end

    # @param key [String]
    # @param amount [Integer, Float]
    # @option expires_in [Integer]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def increment(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)
      is_initial = expires_in && !read(key)

      if is_initial
        write(key, amount, expires_in: expires_in) && amount
      else
        driver.increment(key, amount).tap do
          expire(key, expires_in: expires_in) if expires_in
        end
      end
    end

    # @param key [String]
    # @param amount [Integer, Float]
    # @option expires_in [Integer]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def decrement(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)
      is_initial = expires_in && !read(key)

      if is_initial
        write(key, -amount, expires_in: expires_in) && -amount
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
    # @since 0.1.0
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
    # @since 0.1.0
    def persist(key, **options)
      read(key).tap { |value| write(key, value) }
    end
  end
end
