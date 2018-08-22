# frozen_string_literal: true

class AnyCache::Adapters::ActiveSupportNaiveStore
  # @api private
  # @since 0.1.0
  class Increment < Operation
    # @return [Integer]
    #
    # @api private
    # @since 0.1.0
    DEFAULT_AMOUNT = 1

    # @since 0.1.0
    def_delegators :driver, :increment

    # @param key [String]
    # @param amount [Integer, Float]
    # @option expires_in [NilClass, Integer]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def call(key, amount = DEFAULT_AMOUNT, expires_in: NO_EXPIRATION_TTL)
      expires_in ? incr_and_expire(key, amount, expires_in) : incr_existing(key, amount)
    end

    private

    # @param key [String]
    # @param amount [Integer, Float]
    # @param expires_in [NilClass, Integer]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def incr_and_expire(key, amount, expires_in)
      new_amount = increment(key, amount, expires_in: expires_in)
      new_amount || incr_non_existing(key, amount, expires_in)
    end

    # @param key [String]
    # @param amount [Integer, Float]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def incr_existing(key, amount)
      new_amount = begin
        entry = fetch_entry(key)
        increment(key, amount, expires_in: calc_entry_expiration(entry)) if entry
      end

      new_amount || incr_non_existing(key, amount)
    end

    # @param key [String]
    # @param amount [Integer, Float]
    # @param expires_in [NilClass, Integer]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def incr_non_existing(key, amount, expires_in = NO_EXPIRATION_TTL)
      (expires_in ? write(key, amount, expires_in: expires_in) : write(key, amount)) && amount
    end

    # @!method fetch_entry(key)
    #   @param key [String]
    #   @return [NilClass, ActiveSupport::Cache::Entry]
  end
end
