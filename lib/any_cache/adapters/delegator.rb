# frozen_string_literal: true

module AnyCache::Adapters
  # @api private
  # @since 0.1.0
  class Delegator < Basic
    class << self
      # @param driver [Object]
      # @return [Boolean]
      #
      # @api private
      # @since 0.1.0
      def supported_driver?(driver)
        driver.respond_to?(:read) &&
        driver.respond_to?(:write) &&
        driver.respond_to?(:delete) &&
        driver.respond_to?(:increment) &&
        driver.respond_to?(:decrement) &&
        driver.respond_to?(:expire) &&
        driver.respond_to?(:clear)
      end
    end

    # @since 0.1.0
    def_delegators :driver,
                   :read,
                   :write,
                   :delete,
                   :increment,
                   :decrement,
                   :expire,
                   :clear
  end
end
