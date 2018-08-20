# frozen_string_literal: true

class AnyCache::Adapters::ActiveSupportNaiveStore
  # @api private
  # @since 0.1.0
  class Operation
    # @since 0.1.0
    extend Forwardable

    # @return [NilClass]
    #
    # @api private
    # @since 0.1.0
    NO_EXPIRATION_TTL = nil

    # @since 0.1.0
    def_delegators :driver, :read, :write

    # @param driver [Object]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(driver)
      @driver = driver
    end

    private

    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    attr_reader :driver

    # @option as_integer [Boolean]
    # @return [Integer, Float]
    #
    # @api private
    # @since 0.1.0
    def calc_epoch_time(as_integer: false)
      as_integer ? Time.now.to_i : Time.now.to_f
    end

    # @param [ActiveSupport::Cache::Entry]
    # @return [NilClass, Integer]
    #
    # @api private
    # @since 0.1.0
    def calc_entry_expiration(entry)
      entry.expires_at ? (entry.expires_at - calc_epoch_time) : NO_EXPIRATION_TTL
    end

    # @!method fetch_entry(key)
    #   @param key [String]
    #   @return [NilClass, ActiveSupport::Cache::Entry]
  end
end
