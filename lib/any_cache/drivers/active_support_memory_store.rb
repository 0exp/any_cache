# frozen_string_literal: true

# @api private
# @since 0.2.0
module AnyCache::Drivers::ActiveSupportMemoryStore
  class << self
    # @param driver [::Redis]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def supported_source?(driver)
      defined?(::ActiveSupport::Cache::MemoryStore) &&
      driver.is_a?(::ActiveSupport::Cache::MemoryStore)
    end

    # @param settings [Qonfig::Settings]
    # @return [::Redis]
    #
    # @api private
    # @sicne 0.2.0
    def build(settings)
      ::ActiveSupport::Cache::MemoryStore.new(settings.options)
    end
  end
end
