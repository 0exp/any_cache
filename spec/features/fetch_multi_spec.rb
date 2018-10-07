# frozen_string_literal: true

describe 'Operation: #fetch_multi' do
  include_context 'cache store'

  let(:entry_1) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:entry_2) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:entry_3) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

  let(:expires_in) { 8 } # NOTE: in seconds

  specify 'returns a set of key-value pairs by the given key set' do
    # NOTE: nonexisntent data
    expect(cache_store.fetch_multi(entry_1[:key], entry_2[:key], entry_3[:key])).to match(
      entry_1[:key] => nil,
      entry_2[:key] => nil,
      entry_3[:key] => nil
    )

    cache_store.write_multi(
      entry_1[:key] => entry_1[:value],
      entry_3[:key] => entry_3[:value]
    ) # NOTE: entry_2 doesn't exist yet

    # NOTE: partially existing data
    expect(cache_store.fetch_multi(entry_1[:key], entry_2[:key], entry_3[:key])).to match(
      entry_1[:key] => entry_1[:value],
      entry_2[:key] => nil,
      entry_3[:key] => entry_3[:value]
    )

    # NOTE fetching different count of entries
    expect(cache_store.fetch_multi(entry_1[:key])).to match(
      entry_1[:key] => entry_1[:value]
    ) # NOTE: 1 entry
    expect(cache_store.fetch_multi(entry_1[:key], entry_2[:key])).to match(
      entry_1[:key] => entry_1[:value],
      entry_2[:key] => nil
    ) # NOTE: 2 entries

    # NOTE: write nonexistent entries
    data_stub = SecureRandom.hex(4)
    data = cache_store.fetch_multi(entry_1[:key], entry_2[:key], entry_3[:key]) do |key|
      "#{key}-#{data_stub}"
    end

    # NOTE: entry_2 has especial dynamically calculated value
    expect(data).to match(
      entry_1[:key] => entry_1[:value],
      entry_2[:key] => "#{entry_2[:key]}-#{data_stub}",
      entry_3[:key] => entry_3[:value]
    )

    # NOTE: force rewrite
    data_stub = SecureRandom.hex(4)
    cache_store.fetch_multi(
      entry_1[:key],
      entry_2[:key],
      expires_in: expires_in,
      force: true
    ) do |key|
      "#{key}-#{data_stub}"
    end

    # NOTE: entries with new values (and expiration time)
    expect(cache_store.fetch_multi(entry_1[:key], entry_2[:key], entry_3[:key])).to match(
      entry_1[:key] => "#{entry_1[:key]}-#{data_stub}",
      entry_2[:key] => "#{entry_2[:key]}-#{data_stub}",
      entry_3[:key] => entry_3[:value]
    )

    sleep(expires_in + 1)

    # NOTE: new entries has expired
    expect(cache_store.fetch_multi(entry_1[:key], entry_2[:key], entry_3[:key])).to match(
      entry_1[:key] => nil,
      entry_2[:key] => nil,
      entry_3[:key] => entry_3[:value]
    )
  end
end
