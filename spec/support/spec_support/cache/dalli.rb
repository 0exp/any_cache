# frozen_string_literal: true

module SpecSupport::Cache::Dalli
  class CacheStore < AnyCache
    configure do |conf|
      conf.driver = :dalli
      conf.dalli.servers = '127.0.0.1:11211'
      conf.dalli.options = { namespace: 'any_cache' }
    end
  end

  class << self
    def build
      load_dependencies!
      build_cache_store
    end

    private

    def load_dependencies!
      require 'dalli'
    end

    def build_cache_store
      CacheStore.build
    end
  end
end
