# frozen_string_literal: true

# @api private
# @since 0.5.0
module AnyCache::Plugins::InterfaceAccessMixin
  # @param plugin_name [Symbol, String]
  # @return [void]
  #
  # @see AnyCache::Plugins
  #
  # @api public
  # @since 0.5.0
  def plugin(plugin_name)
    AnyCache::Plugins.load(plugin_name)
  end

  # @return [Array<String>]
  #
  # @see AnyCache::Plugins
  #
  # @api public
  # @since 0.5.0
  def plugins
    AnyCache::Plugins.names
  end
end
