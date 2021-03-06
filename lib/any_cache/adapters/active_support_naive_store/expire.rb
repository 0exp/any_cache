# frozen_string_literal: true

class AnyCache::Adapters::ActiveSupportNaiveStore
  # @api private
  # @since 0.1.0
  class Expire < Operation
    # @param key [String]
    # @option expires_in [Integer, NilClass]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def call(key, expires_in: DEAD_TTL)
      fetch_entry(key).tap do |entry|
        next unless entry
        is_alive = expires_in.positive?
        is_alive ? write(key, entry.value, expires_in: expires_in) : delete(key)
      end
    end

    # @!method fetch_entry(key)
    #   @param key [String]
    #   @return [NilClass, ActiveSupport::Cache::Entry]
  end
end
