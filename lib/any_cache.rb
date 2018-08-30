# frozen_string_literal: true

require 'qonfig'
require 'securerandom'
require 'concurrent/atomic/reentrant_read_write_lock'

# @api public
# @since 0.1.0
class AnyCache
  require_relative 'any_cache/version'
  require_relative 'any_cache/drivers'
  require_relative 'any_cache/adapters'

  # @since 0.1.0
  extend Forwardable

  # @since 0.2.0
  include Qonfig::Configurable

  # @since 0.2.0
  configuration do
    setting :driver

    setting :redis do
      setting :options, {}
    end

    setting :redis_store do
      setting :options, {}
    end

    setting :dalli do
      setting :servers, nil
      setting :options, {}
    end

    setting :as_file_store do
      setting :cache_path
      setting :options, {}
    end

    setting :as_memory_store do
      setting :options, {}
    end

    setting :as_redis_cache_store do
      setting :options, {}
    end
  end

  class << self
    # @param driver [Object]
    # @return [AnyCache]
    #
    # @api private
    # @since 0.1.0
    def build(driver = Drivers.build(config))
      new(Adapters.build(driver))
    end
  end

  # @since 0.1.0
  def_delegators :adapter,
                 :read,
                 :write,
                 :delete,
                 :increment,
                 :decrement,
                 :expire,
                 :persist,
                 :clear

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
