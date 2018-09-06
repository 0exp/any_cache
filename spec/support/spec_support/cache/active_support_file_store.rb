# frozen_string_literal: true

module SpecSupport::Cache::ActiveSupportFileStore
  class CacheStore < AnyCache
    configure do |conf|
      conf.driver = :as_file_store
      conf.logger = SpecSupport::NullLogger
      conf.as_file_store.cache_path = File.expand_path(
        File.join('..', '..', 'artifacts', SecureRandom.hex),
        __dir__
      )
    end
  end

  class << self
    def build
      load_dependencies!
      build_cache_store
    end

    private

    def load_dependencies!
      require 'active_support'
    end

    def build_cache_store
      CacheStore.build
    end
  end
end
