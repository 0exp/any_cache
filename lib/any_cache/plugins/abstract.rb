# frozen_string_literal: true

# @api public
# @since 0.5.0
class AnyCache::Plugins::Abstract
  class << self
    # @return [void]
    #
    # @api private
    # @since 0.5.0
    def load!; end
  end
end
