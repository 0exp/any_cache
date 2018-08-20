# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class ActiveSupportFileStore::ReExpire < ActiveSupportNaiveStore::ReExpire
    # @since 0.1.0
    include ActiveSupportFileStore::Fetching
  end
end
