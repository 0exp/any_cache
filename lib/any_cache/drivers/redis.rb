# frozen_string_literal: true

# @api private
# @since 0.2.0
module AnyCache::Drivers::Redis
  class << self
    # @param driver [::Redis]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def supported_source?(driver)
      defined?(::Redis) && driver.is_a?(::Redis)
    end

    # @param settings [Qonfig::Settings]
    # @return [::Redis]
    #
    # @api private
    # @sicne 0.2.0
    def build(settings)
      ::Redis.new(settings.options)
    end
  end
end
