# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:example, :redis) do |example|
    example.call if test_redis_cache?
  end

  config.around(:example, :redis_store) do |example|
    example.call if test_redis_store_cache
  end

  config.around(:example, :dalli) do |example|
    example.call if test_dalli_cache?
  end

  config.around(:example, :as_redis_cache_store) do |example|
    example.call if test_as_redis_cache_store_cache?
  end

  config.around(:example, :as_mem_cache_store) do |example|
    example.call if test_as_mem_cache_store_cache?
  end

  config.around(:example, :as_file_store) do |example|
    example.call if test_as_file_store_cache?
  end

  config.around(:example, :as_memory_store) do |example|
    example.call if test_as_memory_store_cache?
  end
end
