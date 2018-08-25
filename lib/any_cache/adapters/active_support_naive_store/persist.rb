# frozen_string_literal: true

class AnyCache::Adapters::ActiveSupportNaiveStore
  # @api private
  # @since 0.1.0
  class Persist < Operation
    # @param key [String]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def call(key)
      fetch_entry(key).tap do |entry|
        write(key, entry.value, expires_in: NO_EXPIRATION_TTL) if entry
      end
    end

    # @!method fetch_entry(key)
    #   @param key [String]
    #   @return [NilClass, ActiveSupport::Cache::Entry]
  end
end
