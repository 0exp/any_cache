# frozen_string_literal: true

describe 'Operation: #clear' do
  include_context 'cache store'

  it 'clears storage' do
    # NOTE: write random values
    value_pairs = Array.new(10) { { key: SecureRandom.hex, value: rand(0..10) } }.tap do |pairs|
      pairs.each { |pair| cache_store.write(pair[:key], pair[:value]) }
    end

    # NOTE: clear storage
    cache_store.clear

    # NOTE: check that written values doesnt exist
    value_pairs.each do |pair|
      expect(cache_store.read(pair[:key])).to eq(nil)
    end
  end
end
