# frozen_string_literal: true

module SpecSupport::Cache::ActiveSupportMemoryStore
  class CacheStore < AnyCache
    configure do |conf|
      conf.driver = :as_memory_store
    end
  end

  class << self
    def build
      load_dependencies!
      build_cache_store
    end

    private

    def load_dependencies!
      require 'active_support'
    end

    def build_cache_store
      CacheStore.build
    end
  end
end
