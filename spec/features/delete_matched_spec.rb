# frozen_string_literal: true

describe 'Operation: #delete_matched' do
  include_context 'cache store'

  let(:entry_1) { { key: 'test_1', value: SecureRandom.hex(4) } }
  let(:entry_2) { { key: '2_test', value: SecureRandom.hex(4) } }
  let(:entry_3) { { key: 'no_key', value: SecureRandom.hex(4) } }

  before do
    cache_store.write_multi(
      entry_1[:key] => entry_1[:value],
      entry_2[:key] => entry_2[:value],
      entry_3[:key] => entry_3[:value]
    )
  end

  specify(
    'removes matched keys only (with simple strings support)',
    exclude: %i[dalli as_mem_cache_store as_redis_cache_store as_dalli_store]
  ) do
    expect(cache_store.read(entry_1[:key])).to eq(entry_1[:value])
    expect(cache_store.read(entry_2[:key])).to eq(entry_2[:value])
    expect(cache_store.read(entry_3[:key])).to eq(entry_3[:value])

    cache_store.delete_matched(/\A.*test.*\z/i)

    expect(cache_store.read(entry_1[:key])).to eq(nil)
    expect(cache_store.read(entry_2[:key])).to eq(nil)
    expect(cache_store.read(entry_3[:key])).to eq(entry_3[:value])

    cache_store.delete_matched('no_key')

    expect(cache_store.read(entry_1[:key])).to eq(nil)
    expect(cache_store.read(entry_2[:key])).to eq(nil)
    expect(cache_store.read(entry_3[:key])).to eq(nil)
  end

  specify(
    'removes matched keys only (with redis blob strings support)',
    only: %i[as_redis_cache_store redis redis_store]
  ) do
    expect(cache_store.read(entry_1[:key])).to eq(entry_1[:value])
    expect(cache_store.read(entry_2[:key])).to eq(entry_2[:value])
    expect(cache_store.read(entry_3[:key])).to eq(entry_3[:value])

    cache_store.delete_matched('test?1') # NOTE: redis KEYS glob pattners

    expect(cache_store.read(entry_1[:key])).to eq(nil)
    expect(cache_store.read(entry_2[:key])).to eq(entry_2[:value])
    expect(cache_store.read(entry_3[:key])).to eq(entry_3[:value])

    cache_store.delete_matched('*_*') # NOTE: redis KEYS glob patterns

    expect(cache_store.read(entry_1[:key])).to eq(nil)
    expect(cache_store.read(entry_2[:key])).to eq(nil)
    expect(cache_store.read(entry_3[:key])).to eq(nil)
  end
end
