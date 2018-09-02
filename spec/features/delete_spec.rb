# frozen_string_literal: true

describe 'Operation: #delete' do
  include_context 'cache store'

  it 'removes entry from cache' do
    first_pair  = { key: SecureRandom.hex, value: SecureRandom.hex(4) }
    second_pair = { key: SecureRandom.hex, value: SecureRandom.hex(4) }

    cache_store.write(first_pair[:key], first_pair[:value])
    cache_store.write(second_pair[:key], second_pair[:value])

    cache_store.delete(first_pair[:key])
    expect(cache_store.read(first_pair[:key])).to eq(nil)
    expect(cache_store.read(second_pair[:key])).to eq(second_pair[:value])

    cache_store.delete(second_pair[:key])
    expect(cache_store.read(second_pair[:key])).to eq(nil)
    expect(cache_store.read(second_pair[:key])).to eq(nil)
  end
end
