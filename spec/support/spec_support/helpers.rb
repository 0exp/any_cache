# frozen_string_literal: true

module SpecSupport
  module Helpers
    def build_cache_store
      case
      when Testing.test_redis_cache?
        AnyCache.build(Cache::Redis.connect)
      when Testing.test_redis_store_cache?
        AnyCache.build(Cache::RedisStore.connect)
      when Testing.test_dalli_cache?
        AnyCache.build(Cache::Dalli.connect)
      when Testing.test_as_memory_store_cache?
        AnyCache.build(Cache::ActiveSupportMemoryStore.connect)
      when Testing.test_as_file_store_cache?
        AnyCache.build(Cache::ActiveSupportFileStore.connect)
      when Testing.test_as_redis_cache_store_cache?
        AnyCache.build(Cache::ActiveSupportRedisCacheStore.connect)
      else
        raise 'No cache :('
      end
    end
  end
end
