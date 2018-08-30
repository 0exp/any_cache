# frozen_string_literal: true

module SpecSupport::Cache::RedisStore
  class CacheStore < AnyCache
    configure do |conf|
      conf.driver = :redis_store
      conf.redis_store.options = { host: '127.0.0.1', port: 6379 }
    end
  end

  class << self
    def build
      load_dependencies!
      build_cache_store
    end

    private

    def load_dependencies!
      require 'redis-store'
    end

    def build_cache_store
      CacheStore.build
    end
  end
end
