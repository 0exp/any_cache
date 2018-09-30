# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class Redis < Basic
    class << self
      # @param driver [Object]
      # @return [Boolean]
      #
      # @api private
      # @since 0.1.0
      def supported_driver?(driver)
        AnyCache::Drivers::Redis.supported_source?(driver)
      end
    end

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

    # @return [String]
    #
    # @api private
    # @since 0.3.0
    DELETE_MATCHED_CURSOR_START = '0'

    # @return [Integer]
    #
    # @api private
    # @since 0.3.0
    DELETE_MATCHED_BATCH_SIZE = 10

    # @since 0.1.0
    def_delegators :driver,
                   :get,
                   :set,
                   :setex,
                   :del,
                   :incrby,
                   :decrby,
                   :pipelined,
                   :flushdb,
                   :exists,
                   :mapped_mget,
                   :mapped_mset,
                   :scan

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
      mapped_mget(*keys)
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

      expires_in ? setex(key, expires_in, value) : set(key, value)
    end

    # @param entries [Hash]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def write_multi(entries, **options)
      mapped_mset(entries)
    end

    # @param key [String]
    # @option expires_in [Integer]
    # @option force [Boolean]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def fetch(key, **options, &fallback)
      force_rewrite = options.fetch(:force, false)
      force_rewrite = force_rewrite.call(key) if force_rewrite.respond_to?(:call)

      # NOTE: think about #pipelined
      read(key).tap { |value| return value if value } unless force_rewrite

      yield(key).tap { |value| write(key, value, **options) } if block_given?
    end

    # @param keys [Array<string>]
    # @param options [Hash]
    # @param fallback [Proc]
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
      del(key)
    end

    # @param pattern [String, Regexp]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def delete_matched(pattern, **options)
      cursor = DELETE_MATCHED_CURSOR_START

      case pattern
      when String
        loop do
          cursor, keys = scan(cursor, match: pattern, count: DELETE_MATCHED_BATCH_SIZE)
          del(keys)
          break if cursor == DELETE_MATCHED_CURSOR_START
        end
      when Regexp
        loop do
          cursor, keys = scan(cursor, count: DELETE_MATCHED_BATCH_SIZE)
          del(keys.grep(pattern))
          break if cursor == DELETE_MATCHED_CURSOR_START
        end
      end
    end

    # @param key [String]
    # @param amount [Integer]
    # @option expires_in [NilClass, Integer] Time in seconds
    # @return [NilClass, Integer]
    #
    # @api private
    # @since 0.1.0
    def increment(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)
      new_amount = nil

      pipelined do
        new_amount = incrby(key, amount)
        expire(key, expires_in: expires_in) if expires_in
      end

      new_amount&.value
    end

    # @param key [String]
    # @param amount [Integer]
    # @options expires_in [NillClass, Integer] Time in seconds
    # @return [NillClass, Integer]
    #
    # @api private
    # @since 0.1.0
    def decrement(key, amount = DEFAULT_INCR_DECR_AMOUNT, **options)
      expires_in = options.fetch(:expires_in, NO_EXPIRATION_TTL)
      new_amount = nil

      pipelined do
        new_amount = decrby(key, amount)
        expire(key, expires_in: expires_in) if expires_in
      end

      new_amount&.value
    end

    # @param key [String]
    # @option expires_in [Integer]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def expire(key, expires_in: DEAD_TTL)
      expires_in ||= DEAD_TTL unless expires_in

      driver.expire(key, expires_in)
    end

    # @param key [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def persist(key, **options)
      driver.persist(key)
    end

    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def clear(**options)
      flushdb
    end

    # @param key [String]
    # @param options [Hash]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def exist?(key, **options)
      exists(key)
    end
  end
end
