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
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
      def supported_driver?(driver)
        driver.respond_to?(:read) &&
        driver.respond_to?(:read_multi) &&
        driver.respond_to?(:write) &&
        driver.respond_to?(:write_multi) &&
        driver.respond_to?(:fetch) &&
        driver.respond_to?(:fetch_multi) &&
        driver.respond_to?(:delete) &&
        driver.respond_to?(:delete_matched) &&
        driver.respond_to?(:increment) &&
        driver.respond_to?(:decrement) &&
        driver.respond_to?(:expire) &&
        driver.respond_to?(:persist) &&
        driver.respond_to?(:clear) &&
        driver.respond_to?(:cleanup) &&
        driver.respond_to?(:exist?)
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
    end

    # @since 0.1.0
    def_delegators :driver,
                   :read,
                   :read_multi,
                   :write,
                   :write_multi,
                   :fetch,
                   :fetch_multi,
                   :delete,
                   :delete_matched,
                   :increment,
                   :decrement,
                   :expire,
                   :persist,
                   :clear,
                   :cleanup,
                   :exist?
  end
end
