# frozen_string_literal: true

module AnyCache::Drivers::ActiveSupportDalliStore
  class << self
    # @param driver [::ActiveSupport::Cache::DalliStore]
    # @return [Boolean]
    #
    # @api private
    # @since 0.3.0
    def supported_source?(driver)
      defined?(::Dalli) &&
      defined?(::ActiveSupport::Cache::DalliStore) &&
      driver.is_a?(::ActiveSupport::Cache::DalliStore)
    end

    # @param settings [Qonfig:Settings]
    # @return [::ActiveSupport::Cache::DalliStore]
    #
    # @api private
    # @since 0.3.0
    def build(settings)
      ::ActiveSupport::Cache::DalliStore.new([Array(settings.servers), settings.options])
    end
  end
end
