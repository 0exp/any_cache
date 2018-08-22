# frozen_string_literal: true

describe 'Operation: #re_expire' do
  after { cache_store.clear }

  let(:cache_store) { build_cache_store }

  it 'changes expiration time of entry' do
    pair = { key: SecureRandom.hex, value: SecureRandom.hex(4) }

    # NOTE: remaining time: 8 seconds
    cache_store.write(pair[:key], pair[:value], expires_in: 8)

    # NOTE: remaining time: 4 seconds
    sleep(4)

    # NOTE: remaining time: 8 seconds again
    cache_store.re_expire(pair[:key], expires_in: 8)

    # NOTE: remaining time: 4 seconds
    sleep(4)

    # NOTE: record is alive
    expect(cache_store.read(pair[:key])).to eq(pair[:value])

    # NOTE: remaining time: -1 second
    sleep(5)

    # NOTE: record is dead
    expect(cache_store.read(pair[:key])).to eq(nil)
  end
end
