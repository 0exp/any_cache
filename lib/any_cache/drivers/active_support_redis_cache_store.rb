# frozen_string_literal: true

# @api private
# @since 0.2.0
module AnyCache::Drivers::ActiveSupportRedisCacheStore
  class << self
    # @param driver [::ActiveSupport::Cache::RedisCacheStore]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def supported_source?(driver)
      defined?(::Redis) &&
      defined?(::ActiveSupport::Cache::RedisCacheStore) &&
      driver.is_a?(::ActiveSupport::Cache::RedisCacheStore)
    end

    # @param settings [Qonfig::Settings]
    # @return [::ActiveSupport::Cache::RedisCacheStore]
    #
    # @api private
    # @sicne 0.2.0
    def build(settings)
      ::ActiveSupport::Cache::RedisCacheStore.new(settings.options)
    end
  end
end
