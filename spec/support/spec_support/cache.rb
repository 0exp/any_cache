# frozen_string_literal: true

module SpecSupport::Cache
  require_relative 'cache/dalli'
  require_relative 'cache/redis'
  require_relative 'cache/redis_store'
  require_relative 'cache/active_support_file_store'
  require_relative 'cache/active_support_memory_store'
  require_relative 'cache/active_support_redis_cache_store'
end
