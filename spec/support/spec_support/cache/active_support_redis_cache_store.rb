# frozen_string_literal: true

module SpecSupport::Cache::ActiveSupportRedisCacheStore
  include Qonfig::Configurable

  configuration do
    setting :host, '127.0.0.1'
    setting :port, 6379
  end

  class << self
    def load_dependencies!
      require 'redis'
      require 'active_support'
    end

    def connect
      load_dependencies!

      redis_client = ::Redis.new(host: config[:host], port: config[:port])
      ::ActiveSupport::Cache::RedisCacheStore.new(redis: redis_client)
    end
  end
end
