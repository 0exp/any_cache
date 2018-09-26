# frozen_string_literal: true

module SpecSupport::Testing
  extend self

  def test_redis_cache?
    !!ENV['TEST_REDIS_CACHE']
  end

  def test_redis_store_cache?
    !!ENV['TEST_REDIS_STORE_CACHE']
  end

  def test_dalli_cache?
    !!ENV['TEST_DALLI_CACHE']
  end

  def test_as_memory_store_cache?
    !!ENV['TEST_AS_MEMORY_STORE_CACHE']
  end

  def test_as_file_store_cache?
    !!ENV['TEST_AS_FILE_STORE_CACHE']
  end

  def test_as_redis_cache_store_cache?
    !!ENV['TEST_AS_REDIS_CACHE_STORE_CACHE']
  end

  def test_as_mem_cache_store_cache?
    !!ENV['TEST_AS_MEM_CACHE_STORE_CACHE']
  end
end
