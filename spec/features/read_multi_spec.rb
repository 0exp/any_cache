# frozen_string_literal: true

describe 'Operation: #read_multi' do
  include_context 'cache store'

  let(:entry_1) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:entry_2) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:entry_3) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

  let(:expires_in) { 8 } # NOTE: in seconds

  specify do
    expect(cache_store.read_multi(entry_1[:key], entry_2[:key], entry_3[:key])).to match(
      entry_1[:key] => nil, # NOTE: nonexistent entry
      entry_2[:key] => nil, # NOTE: nonexistent entry
      entry_3[:key] => nil  # NOTE: nonexistent entry
    )

    cache_store.write(entry_1[:key], entry_1[:value])
    cache_store.write(entry_2[:key], entry_2[:value], expires_in: expires_in) # NOTE: would expire
    cache_store.write(entry_3[:key], entry_3[:value])

    expect(cache_store.read_multi(entry_1[:key], entry_2[:key], entry_3[:key])).to match(
      entry_1[:key] => entry_1[:value],
      entry_2[:key] => entry_2[:value],
      entry_3[:key] => entry_3[:value]
    )

    sleep(expires_in + 1) # NOTE: expire temporal entry

    expect(cache_store.read_multi(entry_1[:key], entry_2[:key], entry_3[:key])).to match(
      entry_1[:key] => entry_1[:value],
      entry_2[:key] => nil, # NOTE: expired entry
      entry_3[:key] => entry_3[:value]
    )
  end
end
