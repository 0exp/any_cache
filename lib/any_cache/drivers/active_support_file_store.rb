# frozen_string_literal: true

# @api private
# @since 0.2.0
module AnyCache::Drivers::ActiveSupportFileStore
  class << self
    # @param driver [::Redis]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def supported_source?(driver)
      defined?(::ActiveSupport::Cache::FileStore) &&
      driver.is_a?(::ActiveSupport::Cache::FileStore)
    end

    # @param settings [Qonfig::Settings]
    # @return [::ActiveSupport::Cache::FileStore]
    #
    # @api private
    # @sicne 0.2.0
    def build(settings)
      ::ActiveSupport::Cache::FileStore.new(settings.cache_path, settings.options)
    end
  end
end
