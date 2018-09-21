# frozen_string_literal: true

class AnyCache::Adapters::Redis
  class DeleteMatchedSoftly < DeleteMatchedBasic
    # @param pattern [String]
    # @param options [Hash]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def delete_matched(pattern, **options)
      cursor = CURSOR_LOOP_FLAG

      loop do
        cursor, keys = adapter.scan(cursor, match: pattern, count: BATCH_SIZE)
        adapter.del(keys)
        break if cursor == CURSOR_LOOP_FLAG
      end
    end
  end
end
