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

    def_delegators :driver, :mset

    # @param key [String]
    # @option raw [Boolean]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def read(key, **options)
      raw = options.fetch(:raw, false)
      value = get(key, raw: true)

      raw ? value : detransform_value(value)
    end

    # @param keys [Array<String>]
    # @param options [Hash]
    # @return [Hash]
    #
    # @api private
    # @since 0.3.0
    def read_multi(*keys, **options)
      # NOTE: cant use Redis::Store#mget cuz it has some marshalling errors :(
      Hash[keys.zip(keys.map { |key| read(key, **options) })]
    end

    # @param key [String]
    # @param value [Object]
    # @option expires_in [NilClass, Integer] Time in seconds
    # @option raw [Boolean]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def write(key, value, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)
      raw = options.fetch(:raw, false)
      value = transform_value(value) unless raw

      expires_in ? setex(key, expires_in, value, raw: true) : set(key, value, raw: true)
    end

    # @param entries [Hash]
    # @option raw [Boolean]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def write_multi(entries, **options)
      raw = options.fetch(:raw, false)
      entries = transform_pairset(entries) unless raw

      mset(*entries.to_a.flatten!, raw: true)
    end
  end
end
