# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.2.0
  class ActiveSupportMemCacheStore < Basic
    class << self
      # @param driver [Object]
      # @retunr [Boolean]
      #
      # @api private
      # @since 0.2.0
      def supported_driver?(driver)
        defined?(::Dalli) &&
        defined?(::ActiveSupport::Cache::MemCacheStore) &&
        driver.is_a?(::ActiveSupport::Cache::MemCacheStore)
      end
    end
  end
end
