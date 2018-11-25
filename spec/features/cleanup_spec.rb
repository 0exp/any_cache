# frozen_string_literal: true

describe 'Operation: #cleanup', :focus do
  include_context 'cache store'

  it 'removes expired entries' do
    cache_store.write(:key_1, 'key_1_value', expires_in: 4) # 4 seconds lifetime
    cache_store.write(:key_2, 'key_2_value', expires_in: 8) # 8 seconds lifetime
    cache_store.write(:key_3, 'key_3_value', expires_in: 12) # 12 seconds lifetime
    cache_store.write(:key_4, 'key_4_value', expires_in: 16) # 16 seconds lifetime

    sleep(1) # 1 second left
    cache_store.cleanup
    expect(cache_store.fetch_multi(:key_1, :key_2, :key_3, :key_4)).to match(
      key_1: 'key_1_value',
      key_2: 'key_2_value',
      key_3: 'key_3_value',
      key_4: 'key_4_value',
    )

    sleep(3) # 4 seconds left
    cache_store.cleanup
    expect(cache_store.fetch_multi(:key_1, :key_2, :key_3, :key_4)).to match(
      key_1: nil, # expired
      key_2: 'key_2_value',
      key_3: 'key_3_value',
      key_4: 'key_4_value',
    )

    sleep(4) # 8 seconds left
    cache_store.cleanup
    expect(cache_store.fetch_multi(:key_1, :key_2, :key_3, :key_4)).to match(
      key_1: nil, # expired
      key_2: nil, # expired
      key_3: 'key_3_value',
      key_4: 'key_4_value',
    )

    sleep(4) # 12 seconds left
    cache_store.cleanup
    expect(cache_store.fetch_multi(:key_1, :key_2, :key_3, :key_4)).to match(
      key_1: nil, # expired
      key_2: nil, # expired
      key_3: nil, # expired
      key_4: 'key_4_value',
    )

    sleep(4) # 16 seconds left
    cache_store.cleanup
    expect(cache_store.fetch_multi(:key_1, :key_2, :key_3, :key_4)).to match(
      key_1: nil, # expired
      key_2: nil, # expired
      key_3: nil, # expired
      key_4: nil, # expired
    )
  end
end
