# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class ActiveSupportMemoryStore::Decrement < ActiveSupportNaiveStore::Decrement
    # @since 0.1.0
    include ActiveSupportMemoryStore::Fetching
  end
end
