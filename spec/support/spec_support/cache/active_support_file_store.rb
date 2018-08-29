# frozen_string_literal: true

module SpecSupport::Cache::ActiveSupportFileStore
  class CacheStore < AnyCache
    configure do |conf|
      conf.driver = :as_file_store

      conf.as_file_store.options = {
        file_path: File.expand_path(
          File.join('..', '..', '..', 'artifacts', SecureRandom.hex),
          Pathname.new(__FILE__).realpath
        )
      }
    end
  end

  class << self
    def connect
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
