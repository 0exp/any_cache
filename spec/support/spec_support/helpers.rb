# frozen_string_literal: true

module SpecSupport
  module Helpers
    def build_cache_store
      case
      when Testing.test_redis_cache?
        Cache::Redis.build
      when Testing.test_redis_store_cache?
        Cache::RedisStore.build
      when Testing.test_dalli_cache?
        Cache::Dalli.build
      when Testing.test_as_memory_store_cache?
        Cache::ActiveSupportMemoryStore.build
      when Testing.test_as_file_store_cache?
        Cache::ActiveSupportFileStore.build
      when Testing.test_as_redis_cache_store_cache?
        Cache::ActiveSupportRedisCacheStore.build
      when Testing.test_as_mem_cache_store_cache?
        Cache::ActiveSupportMemCacheStore.build
      when Testing.test_as_dalli_store_cache?
        Cache::ActiveSupportDalliStore.build
      else
        raise 'No cache :('
      end
    end
  end
end
