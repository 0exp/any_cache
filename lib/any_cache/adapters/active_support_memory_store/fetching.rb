# frozen_string_literal: true

class AnyCache::Adapters::ActiveSupportMemoryStore
  # @api private
  # @since 0.1.0
  module Fetching
    # @param key [String]
    # @return [NilClass, ActiveSupport::Cache::Entry]
    #
    # @api private
    # @since 0.1.0
    def fetch_entry(key)
      driver.instance_eval { read_entry(key, {}) }
    end
  end
end
