# frozen_string_literal: true

# @api private
# @since 0.3.1
module AnyCache::Patches::DalliStore
  class << self
    # @return [void]
    #
    # @api private
    # @since 0.3.1
    def enable!
      defined?(::Dalli) &&
      defined?(::ActiveSupport::Cache::DalliStore) &&
      Gem::Version.new(::Dalli::VERSION) <= Gem::Version.new('2.7.8') &&
      ::ActiveSupport::Cache::DalliStore.prepend(ActiveSupportFetchWithKey)
    end
  end

  # @api private
  # @since 0.3.1
  module ActiveSupportFetchWithKey
    # NOTE: original fetch implementation with my own little fix (see #43 line of code below)
    # rubocop:disable all
    def fetch(name, options=nil)
      options ||= {}
      options[:cache_nils] = true if @options[:cache_nils]
      namespaced_name = namespaced_key(name, options)
      not_found = options[:cache_nils] ? Dalli::Server::NOT_FOUND : nil
      if block_given?
        entry = not_found
        unless options[:force]
          entry = instrument_with_log(:read, namespaced_name, options) do |payload|
            read_entry(namespaced_name, options).tap do |result|
              if payload
                payload[:super_operation] = :fetch
                payload[:hit] = not_found != result
              end
            end
          end
        end

        if not_found == entry
          result = instrument_with_log(:generate, namespaced_name, options) do |payload|
            # FIX: https://github.com/petergoldstein/dalli/pull/701
            yield(name)
            # FIX: https://github.com/petergoldstein/dalli/pull/701
          end
          write(name, result, options)
          result
        else
          instrument_with_log(:fetch_hit, namespaced_name, options) { |payload| }
          entry
        end
      else
        read(name, options)
      end
    end
    # rubocop:enable all
  end
end

