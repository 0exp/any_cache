# frozen_string_literal: true

describe 'Command: #fetch' do
  include_context 'cache store'

  let(:entry)      { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:expires_in) { 5 } # NOTE: in seconds

  specify 'fetching without expiration attribue creates a permanent entry' do
    expect(cache_store.fetch(entry[:key])).to eq(nil)

    result = cache_store.fetch(entry[:key]) { entry[:value] }

    expect(result).to eq(entry[:value])
    expect(cache_store.fetch(entry[:key])).to eq(entry[:value])

    sleep(expires_in + 1)

    expect(cache_store.fetch(entry[:key])).to eq(entry[:value])
  end

  specify 'fetching with expiration attribute creates a temporal entry' do
    expect(cache_store.fetch(entry[:key])).to eq(nil)

    result = cache_store.fetch(entry[:key], expires_in: expires_in) { entry[:value] }

    expect(result).to eq(entry[:value])
    expect(cache_store.fetch(entry[:key])).to eq(entry[:value])

    sleep(expires_in + 1)

    expect(cache_store.fetch(entry[:key])).to eq(nil)
  end

  specify 'fetching with :force option creates new entry' do
    expect(cache_store.fetch(entry[:key])).to eq(nil)

    # NOTE: initial permanent entry
    entry_value = SecureRandom.hex(4)
    result = cache_store.fetch(entry[:key], force: true) { entry_value }

    expect(result).to eq(entry_value)
    expect(cache_store.fetch(entry[:key])).to eq(entry_value)

    # NOTE: new permanent value
    entry_value = SecureRandom.hex(4)
    result = cache_store.fetch(entry[:key], force: true) { entry_value }

    expect(result).to eq(entry_value)
    expect(cache_store.fetch(entry[:key])).to eq(entry_value)

    # NOTE: new temporal entry
    entry_value = SecureRandom.hex(4)
    result = cache_store.fetch(entry[:key], expires_in: expires_in, force: true) do
      entry_value
    end

    expect(result).to eq(entry_value)
    expect(cache_store.fetch(entry[:key])).to eq(entry_value)
    sleep(expires_in + 1) # NOTE: expire new temporal entry
    expect(cache_store.fetch(entry[:key])).to eq(nil)

    # NOTE: prepare new temporal entry
    entry_value = SecureRandom.hex(4)
    cache_store.write(entry[:key], entry[:value], expires_in: expires_in)

    # NOTE: rewrite new temporal entry with permanent entry
    result = cache_store.fetch(entry[:key], force: true) { entry_value }
    expect(result).to eq(entry_value)
    expect(cache_store.fetch(entry[:key])).to eq(entry_value)

    sleep(expires_in + 1) # NOTE: try to expire rewritten entry

    expect(cache_store.fetch(entry[:key])).to eq(entry_value)
  end
end
