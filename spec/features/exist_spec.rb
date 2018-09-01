# frozen_string_literal: true

describe 'Operation: #exist?' do
  after { cache_store.clear }

  let(:cache_store)     { build_cache_store }
  let(:expiration_time) { 8 } # NOTE: in seconds
  let(:entry)           { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

  context 'entry with expiration time' do
    before { cache_store.write(entry[:key], entry[:value], expires_in: expiration_time) }

    specify 'returns corresponding value (exists => true, does not exist => false)' do
      expect(cache_store.exist?(entry[:key])).to eq(true)

      sleep(expiration_time + 1)

      expect(cache_store.exist?(entry[:key])).to eq(false)
    end
  end

  context 'when entry exists' do
    before { cache_store.write(entry[:key], entry[:value]) }

    it 'returns true' do
      expect(cache_store.exist?(entry[:key])).to eq(true)
    end
  end

  context 'when entry does not exist' do
    it 'returns false' do
      expect(cache_store.exist?(entry[:key])).to eq(false)
    end
  end
end
