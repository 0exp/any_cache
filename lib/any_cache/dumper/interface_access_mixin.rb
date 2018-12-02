# frozen_string_literal: true

# @api private
# @since 0.4.0
module AnyCache::Dumper::InterfaceAccessMixin
  # @param value [Object]
  # @return [Object]
  #
  # @api private
  # @since 0.4.0
  def transform_value(value)
    AnyCache::Dumper.dump(value)
  end

  # @param value [Object]
  # @return [Object]
  #
  # @api private
  # @since 0.4.0
  def detransform_value(value)
    AnyCache::Dumper.load(value)
  end

  # @param pairset [Hash]
  # @return [Hash]
  #
  # @api private
  # @since 0.4.0
  def transform_pairset(pairset)
    AnyCache::Dumper.transform_hash(pairset)
  end

  # @param pairset [Hash]
  # @return [Hash]
  #
  # @api private
  # @since 0.4.0
  def detransform_pairset(pairset)
    AnyCache::Dumper.detransform_hash(pairset)
  end
end
