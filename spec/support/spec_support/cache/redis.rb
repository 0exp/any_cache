# frozen_string_literal: true

module SpecSupport::Cache::Redis
  include Qonfig::Configurable

  configuration do
    setting :host, '127.0.0.1'
    setting :port, 6379
  end

  class << self
    def load_dependencies!
      require 'redis'
    end

    def connect
      load_dependencies!

      ::Redis.new(host: config[:host], port: config[:port])
    end
  end
end
