# frozen_string_literal: true

module SpecSupport::Cache::RedisStore
  include Qonfig::Configurable

  configuration do
    setting :host, '127.0.0.1'
    setting :port, 6379
  end

  class << self
    def load_dependencies!
      require 'redis-store'
    end

    def connect
      load_dependencies!

      ::Redis::Store.new(host: config[:host], port: config[:port])
    end
  end
end
