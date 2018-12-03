# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class Basic
    # @since 0.1.0
    extend Forwardable
    # @since 0.4.0
    include AnyCache::Dumper::InterfaceAccessMixin

    class << self
      # @param driver [Object]
      # @return [Boolean]
      #
      # @api private
      # @since 0.1.0
      def supported_driver?(driver)
        false
      end
    end

    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    attr_reader :driver

    # @param driver [Object]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(driver)
      @driver = driver
    end

    # @param key [String]
    # @param options [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def read(key, **options)
      raise NotImplementedError
    end

    # @param keys [Array<String>]
    # @param options [Hash]
    # @return [Hash]
    #
    # @api private
    # @since 0.3.0
    def read_multi(*keys, **options)
      raise NotImplementedError
    end

    # @param key [String]
    # @param value [Object]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @sinc 0.1.0
    def write(key, value, **options)
      raise NotImplementedError
    end

    # @param entries [Hash]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def write_multi(entries, **options)
      raise NotImplementedError
    end

    # @param key [String]
    # @param options [Hash]
    # @param fallback [Proc]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def fetch(key, **options, &fallback)
      raise NotImplementedError
    end

    # @param keys [Array<String>]
    # @param options [Hash]
    # @param fallback [Proc]
    # @return [Hash]
    #
    # @api private
    # @since 0.3.0
    def fetch_multi(*keys, **options, &fallback)
      raise NotImplementedError
    end

    # @param key [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def delete(key, **options)
      raise NotImplementedError
    end

    # @param pattern [Regexp, String, Object]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def delete_matched(pattern, **options)
      raise NotImplementedError
    end

    # @param key [String]
    # @param value [Integer, Float]
    # @param options [Hash]
    # @return [Integer, Float]
    #
    # @api private
    # @sinc 0.1.0
    def increment(key, value, **options)
      raise NotImplementedError
    end

    # @param key [String]
    # @param value [Integer, Float]
    # @param options [Hash]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def decrement(key, value, **options)
      raise NotImplementedError
    end

    # @param key [String]
    # @option expires_in [Integer]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def expire(key, expires_in:)
      raise NotImplementedError
    end

    # @param key [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def persist(key, **options)
      raise NotImplementedError
    end

    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def clear(**options)
      raise NotImplementedError
    end

    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.4.0
    def cleanup(**options)
      raise NotImplementedError
    end

    # @param key [String]
    # @param options [Hash]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def exist?(key, **options)
      raise NotImplementedError
    end
  end
end
