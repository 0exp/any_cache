# frozen_string_literal: true

# @api private
# @since 0.4.0
module AnyCache::Dumper
  require_relative 'dumper/interface_access_mixin'

  class << self
    # @param hash [Hash]
    # @return [Hash]
    #
    # @api private
    # @since 0.4.0
    def transform_hash(hash)
      {}.tap do |entries|
        hash.each_pair do |key, value|
          entries[key] = dump(value)
        end
      end
    end

    # @param hash [Hash]
    # @return [Hash]
    #
    # @api private
    # @since 0.4.0
    def detransform_hash(hash)
      {}.tap do |entries|
        hash.each_pair do |key, value|
          entries[key] = load(value)
        end
      end
    end

    # @param value [Object]
    # @return [String]
    #
    # @api private
    # @since 0.4.0
    def dump(value)
      return value if value.nil?
      Zlib::Deflate.deflate(Marshal.dump(value))
    end

    # @param value [String]
    # @return [Object]
    #
    # @api private
    # @since 0.4.0
    def load(value)
      return value if value.nil?
      Marshal.load(Zlib::Inflate.inflate(value))
    end
  end
end
