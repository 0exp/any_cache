# frozen_string_literal: true

# @api private
# @since 0.3.0
module AnyCache::Logging::Activity
  # @return [String]
  #
  # @api private
  # @since 0.3.0
  ANONYMOUS_CACHER_CLASS_NAME = '<__anonymous_cache__>'

  class << self
    # @param cacher [AnyCache]
    # @param logger [::Logger]
    # @option activity [String, NilClass]
    # @option message [String, NillClass]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def log(cacher, logger, activity: nil, message: nil)
      cacher = cacher.class.name || ANONYMOUS_CACHER_CLASS_NAME
      progname = "[AnyCache<#{cacher}>/Activity<#{activity}>]"
      logger.add(logger.level, message, progname)
    end
  end
end
