# frozen_string_literal: true

class AnyCache::Adapters::Redis
  class DeleteMatchedBasic
    # @since 0.3.0
    extend Forwardable

    # @return [String]
    #
    # @api private
    # @since 0.3.0
    CURSOR_LOOP_FLAG = "0"

    # @return [Integer]
    #
    # @api private
    # @since 0.3.0
    BATCH_SIZE = 10

    # @return [AnyCache::Adapters::Redis]
    #
    # @api private
    # @since 0.3.0
    attr_reader :adapter

    # @param adapter [AnyCache::Adapters::Redis]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def initiaalize(adapter)
      @adapter = adapter
    end

    # @!method delete_matched(pattern, **options)
    #   @param pattern [Object]
    #   @param options [Hash]
    #   @return [void]
  end
end
