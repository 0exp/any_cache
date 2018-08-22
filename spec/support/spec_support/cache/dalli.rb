# frozen_string_literal: true

module SpecSupport::Cache::Dalli
  include Qonfig::Configurable

  configuration do
    setting :host, '127.0.0.1'
    setting :port, 11211
    setting :namespace, 'blastwave'
  end

  class << self
    def load_dependencies!
      require 'dalli'
    end

    def connect
      load_dependencies!

      address = "#{config[:host]}:#{config[:port]}"
      options = { namespace: config[:namespace] }

      ::Dalli::Client.new(address, options)
    end
  end
end
