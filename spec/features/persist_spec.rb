# frozen_string_literal: true

describe 'Operation: #persist' do
  include_context 'cache store'

  let(:first_entry)  { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:second_entry) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

  it 'makes entry permanent (removes entry\'s expiration time attribute)' do
    # NOTE: remaining time for first_entry: 8 seconds
    cache_store.write(first_entry[:key], first_entry[:value], expires_in: 8)

    # NOTE: create permanent entry
    cache_store.write(second_entry[:key], second_entry[:value])

    # NOTE: make first_entry permament
    cache_store.persist(first_entry[:key])

    # NOTE: remaining time for first_entry: -1 seconds
    sleep(9)

    # NOTE: first_entry is alive
    expect(cache_store.read(first_entry[:key])).to eq(first_entry[:value])
    # NOTE: second_entry is alive
    expect(cache_store.read(second_entry[:key])).to eq(second_entry[:value])
  end
end
