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
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def supported_driver?(driver)
        driver.respond_to?(:read) &&
        driver.respond_to?(:read_multi) &&
        driver.respond_to?(:write) &&
        driver.respond_to?(:write_multi) &&
        driver.respond_to?(:fetch_multi) &&
        driver.respond_to?(:delete) &&
        driver.respond_to?(:increment) &&
        driver.respond_to?(:decrement) &&
        driver.respond_to?(:expire) &&
        driver.respond_to?(:persist) &&
        driver.respond_to?(:clear) &&
        driver.respond_to?(:exist?) &&
        driver.respond_to?(:fetch)
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end

    # @since 0.1.0
    def_delegators :driver,
                   :read,
                   :read_multi,
                   :write,
                   :write_multi,
                   :fetch_multi,
                   :delete,
                   :increment,
                   :decrement,
                   :expire,
                   :persist,
                   :clear,
                   :exist?,
                   :fetch
  end
end
