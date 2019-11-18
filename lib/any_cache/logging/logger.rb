# frozen_string_literal: true

# @api public
# @since 0.3.0
class AnyCache::Logging::Logger < ::Logger
  # @api public
  # @since 0.3.0
  def initialize(*, **)
    super
    self.level = ::Logger::INFO # TODO: use configuration from the adapter instance
  end
end
