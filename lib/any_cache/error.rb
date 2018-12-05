# frozen_string_literal: true

# @api private
# @since 0.1.0
class AnyCache
  # @since 0.1.0
  Error = Class.new(StandardError)

  # @since 0.1.0
  UnsupportedDriverError = Class.new(Error)

  # @since 0.3.1
  NonexistentPatchError = Class.new(Error)

  # @since 0.5.0
  AlreadyRegisteredPluginError = Class.new(StandardError)

  # @since 0.5.0
  UnregisteredPluginError = Class.new(StandardError)
end
