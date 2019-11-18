# frozen_string_literal: true

# @api private
# @since 0.3.0
module AnyCache::Delegation
  class << self
    # @param base_klass [Class]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def included(base_klass)
      base_klass.extend(ClassMethods)
    end
  end

  # @api private
  # @since 0.3.0
  module ClassMethods
    # @param receiver [Symbol, String]
    # @param delegators [Array<Symbol, String>]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def def_loggable_delegators(receiver, *delegators)
      delegators.each { |delegat| def_loggable_delegator(receiver, delegat) }
    end

    # @param receiver [Symbol, String]
    # @param delegat [Symbol, String]
    # @return [void]
    #
    # @api private
    # @since 0.3.0
    def def_loggable_delegator(receiver, delegat)
      # TODO: move to Instrumentation API
      define_method(delegat) do |*args, **opts, &block|
        send(receiver).send(delegat, *args, **opts, &block).tap do
          shared_config[:logger].tap do |logger|
            AnyCache::Logging::Activity.log(
              self, logger, activity: delegat, message:
                "performed <#{delegat}> operation with " \
                "attributes: #{args.inspect} and options: #{opts.inspect}."
            ) if logger
          end
        end
      end
    end
  end
end
