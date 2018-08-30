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
        AnyCache::Drivers::ActiveSupportMemoryStore.supported_source?(driver)
      end
    end
  end
end
