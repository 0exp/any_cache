# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class RedisStore < Redis
    class << self
      # @param driver [Object]
      # @return [Boolean]
      #
      # @api private
      # @since 0.1.0
      def supported_driver?(driver)
        AnyCache::Drivers::RedisStore.supported_source?(driver)
      end
    end

    # @param key [String]
    # @param options [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def read(key, **options)
      raw = options.fetch(:raw, true)

      get(key, raw: raw)
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
      raw = options.fetch(:raw, true)

      expires_in ? setex(key, expires_in, value, raw: raw) : set(key, value, raw: raw)
    end
  end
end
