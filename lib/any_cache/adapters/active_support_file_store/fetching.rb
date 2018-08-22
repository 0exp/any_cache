# frozen_string_literal: true

class AnyCache::Adapters::ActiveSupportFileStore
  # @api private
  # @since 0.1.0
  module Fetching
    # @param key [String]
    # @return [NilClass, ActiveSupport::Cache::Entry]
    #
    # @api private
    # @since 0.1.0
    def fetch_entry(key)
      driver.instance_eval do
        read_options   = merged_options(nil)
        searched_entry = nil

        search_dir(cache_path) do |fname|
          entry_object = read_entry(fname, read_options)
          entry_name   = file_path_key(fname)

          searched_entry = entry_object if entry_name == key
        end

        searched_entry
      end
    end
  end
end
