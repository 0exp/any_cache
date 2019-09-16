# frozen_string_literal: true

require 'logger'
require 'qonfig'
require 'securerandom'
require 'concurrent/atomic/reentrant_read_write_lock'

# @api public
# @since 0.1.0
class AnyCache
  require_relative 'any_cache/version'
  require_relative 'any_cache/error'
  require_relative 'any_cache/dumper'
  require_relative 'any_cache/drivers'
  require_relative 'any_cache/adapters'
  require_relative 'any_cache/logging'
  require_relative 'any_cache/delegation'
  require_relative 'any_cache/patches'
  require_relative 'any_cache/plugins'

  # @since 0.2.0
  include Qonfig::Configurable
  # @since 0.3.0
  include Delegation
  # @since 0.3.1
  extend Patches::InterfaceAccessMixin
  # @since 0.5.0
  extend Plugins::InterfaceAccessMixin

  # @since 0.2.0
  # rubocop:disable Metrics/BlockLength
  configuration do
    setting :driver

    setting :logger, Logging::Logger.new(STDOUT)

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

    setting :as_mem_cache_store do
      setting :servers, nil
      setting :options, {}
    end

    setting :as_dalli_store do
      setting :servers, nil
      setting :options, {}
    end
  end
  # rubocop:enable Metrics/BlockLength

  class << self
    # @param driver [Object]
    # @return [AnyCache]
    #
    # @api public
    # @since 0.1.0
    def build(driver = Drivers.build(config))
      new(Adapters.build(driver))
    end
  end

  # @api public
  # @since 0.3.0
  def_loggable_delegators :adapter,
                          :read,
                          :read_multi,
                          :write,
                          :write_multi,
                          :fetch,
                          :fetch_multi,
                          :delete,
                          :delete_matched,
                          :increment,
                          :decrement,
                          :expire,
                          :persist,
                          :clear,
                          :cleanup,
                          :exist?

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

# NOTE: Suppot for <RubyOnRails>
require_relative 'active_support/cache/any_cache'
