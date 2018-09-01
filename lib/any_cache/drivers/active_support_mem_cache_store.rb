# frozen_string_literal: true

module AnyCache::Drivers::ActiveSupportMemCacheStore
  class << self
    # @param driver [::ActiveSupport::Cache::MemCacheStore]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def supported_source?(driver)
      defined?(::Dalli) &&
      defined?(::ActiveSupport::Cache::MemCacheStore) &&
      driver.is_a?(::ActiveSupport::Cache::MemCacheStore)
    end

    # @param settings [Qonfig:Settings]
    # @return [::ActiveSupport::Cache::MemCacheStore]
    #
    # @api private
    # @since 0.2.0
    def build(settings)
      ::ActiveSupport::Cache::MemCacheStore.new([Array(settings.servers), settings.options])
    end
  end
end
