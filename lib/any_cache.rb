# frozen_string_literal: true

# @api public
# @since 0.1.0
class AnyCache
  require_relative 'any_cache/version'
  require_relative 'any_cache/adapters'

  # @since 0.1.0
  extend Forwardable

  class << self
    # @param driver [Object]
    # @return [AnyCache]
    #
    # @api private
    # @since 0.1.0
    def build(driver)
      new(Adapters.build(driver))
    end
  end

  # @since 0.1.0
  def_delegators :adapter, :read, :write, :delete, :increment, :decrement, :re_expire, :clear

  # @return [AnyCache::Adapters::Basic]
  #
  # @api private
  # @since 0.1.0
  attr_reader :adapter

  # @param adapter [AnyCache::Adapters::Basic]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def initialize(adapter)
    @adapter = adapter
  end
end
