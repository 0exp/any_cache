# frozen_string_literal: true

module SpecSupport::Cache::ActiveSupportDalliStore
  class CacheStore < AnyCache
    configure do |conf|
      conf.driver = :as_dalli_store
      conf.logger = SpecSupport::NullLogger
      conf.as_dalli_store.servers = '127.0.0.1:11211'
      conf.as_dalli_store.options = { namespace: 'any_cache' }
    end
  end

  class << self
    def build
      load_dependencies!
      build_cache_store
    end

    private

    def load_dependencies!
      require 'dalli'
      require 'active_support'
      require 'active_support/cache/dalli_store'
    end

    def build_cache_store
      CacheStore.build
    end
  end
end
