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

  config.around(:example, :as_dalli_store) do |example|
    example.call if test_as_dalli_store_cache?
  end

  # rubocop:disable Metrics/LineLength
  config.around(:example, :exclude) do |example|
    next if test_redis_cache?                && example.metadata[:exclude].include?(:redis)
    next if test_redis_store_cache?          && example.metadata[:exclude].include?(:redis_store)
    next if test_dalli_cache?                && example.metadata[:exclude].include?(:dalli)
    next if test_as_redis_cache_store_cache? && example.metadata[:exclude].include?(:as_redis_cache_store)
    next if test_as_mem_cache_store_cache?   && example.metadata[:exclude].include?(:as_mem_cache_store)
    next if test_as_file_store_cache?        && example.metadata[:exclude].include?(:as_file_store)
    next if test_as_memory_store_cache?      && example.metadata[:exclude].include?(:as_memory_store)
    next if test_as_dalli_store_cache?       && example.metadata[:exclude].include?(:as_dalli_store)

    example.call
  end
  # rubocop:enable Metrics/LineLength

  # rubocop:disable Metrics/LineLength
  config.around(:example, :only) do |example|
    next if test_redis_cache?                && !example.metadata[:only].include?(:redis)
    next if test_redis_store_cache?          && !example.metadata[:only].include?(:redis_store)
    next if test_dalli_cache?                && !example.metadata[:only].include?(:dalli)
    next if test_as_redis_cache_store_cache? && !example.metadata[:only].include?(:as_redis_cache_store)
    next if test_as_mem_cache_store_cache?   && !example.metadata[:only].include?(:as_mem_cache_store)
    next if test_as_file_store_cache?        && !example.metadata[:only].include?(:as_file_store)
    next if test_as_memory_store_cache?      && !example.metadata[:only].include?(:as_memory_store)
    next if test_as_dalli_store_cache?       && !example.metadata[:only].include?(:as_dalli_store)

    example.call
  end
  # rubocop:enable Metrics/LineLength
end
