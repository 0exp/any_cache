# frozen_string_literal: true

# @api private
# @since 0.2.0
module AnyCache::Drivers
  require_relative 'drivers/dalli'
  require_relative 'drivers/redis'
  require_relative 'drivers/redis_store'
  require_relative 'drivers/active_support_file_store'
  require_relative 'drivers/active_support_memory_store'
  require_relative 'drivers/active_support_redis_cache_store'
  require_relative 'drivers/active_support_mem_cache_store'
  require_relative 'drivers/active_support_dalli_store'

  class << self
    # @param config [Qonfig::DataSet]
    # @return [Object]
    #
    # @raise [AnyCache::UnsupportedDriverError]
    #
    # @api private
    # @since 0.2.0
    def build(config)
      driver = config[:driver]

      case driver
      when :redis
        Redis.build(config[:redis])
      when :redis_store
        RedisStore.build(config[:redis_store])
      when :dalli
        Dalli.build(config[:dalli])
      when :as_file_store
        ActiveSupportFileStore.build(config[:as_file_store])
      when :as_memory_store
        ActiveSupportMemoryStore.build(config[:as_memory_store])
      when :as_redis_cache_store
        ActiveSupportRedisCacheStore.build(config[:as_redis_cache_store])
      when :as_mem_cache_store
        ActiveSupportMemCacheStore.build(config[:as_mem_cache_store])
      when :as_dalli_store
        ActiveSupportDalliStore.build(config[:as_dalli_store])
      else
        raise AnyCache::UnsupportedDriverError
      end
    end
  end
end
