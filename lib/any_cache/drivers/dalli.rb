# frozen_string_literal: true

# @api private
# @since 0.2.0
module AnyCache::Drivers::Dalli
  class << self
    # @param driver [::Dalli::Client]
    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def supported_source?(driver)
      defined?(::Dalli::Client) && driver.is_a?(::Dalli::Client)
    end

    # @param settings [Qonfig::Settings]
    # @return [::Redis]
    #
    # @api private
    # @sicne 0.2.0
    def build(settings)
      ::Dalli::Client.new(settings.servers, settings.options)
    end
  end
end
