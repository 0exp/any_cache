# frozen_string_literal: true

module SpecSupport::Cache::ActiveSupportRedisCacheStore
  class CacheStore < AnyCache
    configure do |conf|
      conf.driver = :as_redis_cache_store
      conf.logger = SpecSupport::NullLogger
    end
  end

  class << self
    def build
      load_dependencies!
      build_cache_store
    end

    private

    def load_dependencies!
      require 'redis'
      require 'active_support'
    end

    def build_cache_store
      CacheStore.configure do |conf|
        conf.as_redis_cache_store.options = {
          redis: ::Redis.new(
            host: '127.0.0.1',
            port: 6379
          )
        }
      end

      CacheStore.build
    end
  end
end
