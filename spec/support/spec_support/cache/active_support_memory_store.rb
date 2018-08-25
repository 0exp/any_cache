# frozen_string_literal: true

module SpecSupport::Cache::ActiveSupportMemoryStore
  class << self
    def connect
      load_dependencies!

      ::ActiveSupport::Cache::MemoryStore.new
    end

    private

    def load_dependencies!
      require 'active_support'
    end
  end
end
