# frozen_string_literal: true

# @api private
# @since 0.2.0
module AnyCache::Drivers::RedisStore
  class << self
    # @param driver [::Redis]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def supported_source?(driver)
      defined?(::Redis::Store) && driver.is_a?(::Redis::Store)
    end

    # @param settings [Qonfig::Settings]
    # @return [::Redis::Store]
    #
    # @api private
    # @sicne 0.2.0
    def build(settings)
      ::Redis::Store.new(settings.options)
    end
  end
end
