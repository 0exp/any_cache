# frozen_string_literal: true

module AnyCache::Logging
  # @api private
  # @since 0.3.0
  class Logger < ::Logger
    # @api private
    # @since 0.3.0
    def initialize(*, **)
      super
      self.level = ::Logger::INFO
    end
  end

  # @api private
  # @since 0.3.0
  module Activity
    # @return [String]
    #
    # @api private
    # @since 0.3.0
    ANONYMOUS_CACHER_INSTANCE_NAME = '<anonymous_cache>'

    class << self
      # @param cacher [AnyCache]
      # @param logger [::Logger]
      # @option activity [String, NilClass]
      # @param message [String, NillClass]
      # @return [void]
      #
      # @api private
      # @since 0.3.0
      def log(cacher, logger, activity: nil, message: nil)
        cacher = cacher.class.name || ANONYMOUS_CACHER_INSTANCE_NAME
        progname = "[AnyCache<#{cacher}>/Activity<#{activity}>]"
        logger.add(logger.level, message, progname)
      end
    end
  end
end
