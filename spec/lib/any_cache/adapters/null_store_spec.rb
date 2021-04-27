# frozen_string_literal: true

require "spec_helper"

describe "::AnyCache::Adapters::NullStore" do
  it "has a null store if it's been explicitly loaded" do
    load "any_cache/adapters/null_store.rb"

    expect(AnyCache.build(nil).adapter).to be_instance_of(AnyCache::Adapters::NullStore)
  end

  it "doesn't load unless it's been explicitly loaded" do
    AnyCache::Adapters.send(:remove_const, :NullStore) if AnyCache::Adapters.constants.include?(:NullStore)

    expect { AnyCache.build(nil).adapter }.to raise_error(AnyCache::UnsupportedDriverError)
  end
end
