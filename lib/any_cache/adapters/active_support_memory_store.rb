# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class ActiveSupportMemoryStore < ActiveSupportNaiveStore
    require_relative 'active_support_memory_store/fetching'
    require_relative 'active_support_memory_store/operation'
    require_relative 'active_support_memory_store/increment'
    require_relative 'active_support_memory_store/decrement'
    require_relative 'active_support_memory_store/expire'
    require_relative 'active_support_memory_store/persist'

    class << self
      # @param driver [Object]
      # @return [Boolean]
      #
      # @api private
      # @since 0.1.0
      def supported_driver?(driver)
        defined?(::ActiveSupport::Cache::MemoryStore) &&
        driver.is_a?(::ActiveSupport::Cache::MemoryStore)
      end
    end
  end
end
