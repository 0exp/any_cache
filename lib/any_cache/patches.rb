# frozen_string_literal: true

# @api private
# @since 0.3.1
module AnyCache::Patches
  # @since 0.3.1
  require_relative 'patches/dalli_store'

  class << self
    # @param patch_series [Symbol, String]
    # @return [void]
    #
    # @raise [AnyCache::NonexistentPatchError]
    #
    # @api private
    # @since 0.3.1
    def enable!(patch_series)
      case patch_series
      when :dalli_store, 'dalli_store'
        AnyCache::Patches::DalliStore.enable!
      else
        raise AnyCache::NonexistentPatchError, "Can't enable nonexistnet patch! (#{patch_series})"
      end
    end
  end

  # @api private
  # @since 0.3.1
  module InterfaceAccessMixin
    # @param patch_series [Symbol, String]
    # @return [void]
    #
    # @see AnyCache::Patches#enable!
    #
    # @api private
    # @since 0.3.1
    def enable_patch!(patch_series)
      AnyCache::Patches.enable!(patch_series)
    end
  end
end
