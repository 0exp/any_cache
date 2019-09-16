# frozen_string_literal: true

# @api public
# @since 0.7.0
module ActiveSupport
  # @api public
  # @since 0.7.0
  module Cache
    # @api public
    # @since 0.7.0
    class AnyCache
      # @api private
      # @since 0.7.0
      extend Forwardable

      # @api public
      # @since 0.7.0
      def_delegators :client, :fetch,
                              :fetch_multi,
                              :read,
                              :read_multi,
                              :write,
                              :write_multi,
                              :delete,
                              :delete_matched,
                              :increment,
                              :decrement,
                              :expire,
                              :persist,
                              :exist?,
                              :clear,
                              :cleanup

      # @option driver [Symbol]
      # @option driver_options [Hash]
      # @return [void]
      #
      # @api private
      # @since 0.7.0
      def initialize(driver:, **configs)
        @client_klass = Class.new(::AnyCache).tap do |klass|
          klass.configure(driver: driver, **configs)
        end

        @client = client_klass.build
      end

      private

      # @return [Class<AnyCache>]
      #
      # @api private
      # @since 0.7.0
      attr_reader :client_klass

      # @return [AnyCache]
      #
      # @api private
      # @since 0.7.0
      attr_reader :client
    end
  end
end
