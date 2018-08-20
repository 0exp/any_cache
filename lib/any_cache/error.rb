# frozen_string_literal: true

# @api private
# @since 0.1.0
class AnyCache
  # @since 0.1.0
  Error = Class.new(StandardError)

  # @since 0.1.0
  UnsupportedDriverError = Class.new(Error)
end
