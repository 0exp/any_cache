# frozen_string_literal: true

describe 'Operation: #write_multi' do
  include_context 'cache store'

  let(:entry_1) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:entry_2) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:entry_3) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

  specify 'writes a set of permanent entries' do
    expect(cache_store.read(entry_1[:key])).to eq(nil) # NOTE: nonexistent entry
    expect(cache_store.read(entry_2[:key])).to eq(nil) # NOTE: nonexistent entry
    expect(cache_store.read(entry_3[:key])).to eq(nil) # NOTE: nonexistent entry

    cache_store.write_multi(
      entry_1[:key] => entry_1[:value], # NOTE: permanent entry
      entry_2[:key] => entry_2[:value], # NOTE: permanent entry
      entry_3[:key] => entry_3[:value]  # NOTE: permanent entry
    )

    expect(cache_store.read(entry_1[:key])).to eq(entry_1[:value])
    expect(cache_store.read(entry_2[:key])).to eq(entry_2[:value])
    expect(cache_store.read(entry_3[:key])).to eq(entry_3[:value])

    new_entry_1_value = SecureRandom.hex(4)
    new_entry_2_value = SecureRandom.hex(4)

    cache_store.write_multi(
      entry_1[:key] => new_entry_1_value, # NOTE: rewrite
      entry_2[:key] => new_entry_2_value, # NOTE: rewrite
      entry_3[:key] => entry_3[:value]    # NOTE: rewrite
    )

    expect(cache_store.read(entry_1[:key])).to eq(new_entry_1_value)
    expect(cache_store.read(entry_2[:key])).to eq(new_entry_2_value)
    expect(cache_store.read(entry_3[:key])).to eq(entry_3[:value])
  end
end
