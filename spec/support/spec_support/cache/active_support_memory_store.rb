# frozen_string_literal: true

module SpecSupport::Cache::ActiveSupportMemoryStore
  class << self
    def load_dependencies!
      require 'active_support'
    end

    def connect
      load_dependencies!

      ::ActiveSupport::Cache::MemoryStore.new
    end
  end
end
