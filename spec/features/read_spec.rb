# frozen_string_literal: true

describe 'Operation: #read' do
  include_context 'cache store'

  context 'when the required entry exists' do
    let(:expiration_time) { 8 } # NOTE: in seconds
    let(:entry) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

    context 'and entiry without expiration' do
      before { cache_store.write(entry[:key], entry[:value]) }

      it 'returns entry value: exists => entry value; doesnt exist => nil' do
        expect(cache_store.read(entry[:key])).to eq(entry[:value])
        sleep(expiration_time + 1) # NOTE: remaining time: -1 seconds
        expect(cache_store.read(entry[:key])).to eq(entry[:value])
      end
    end

    context 'and entry with expiration' do
      before { cache_store.write(entry[:key], entry[:value], expires_in: expiration_time) }

      it 'returns corresponding value: alive => entry value, expired => nil' do
        expect(cache_store.read(entry[:key])).to eq(entry[:value])
        sleep(expiration_time + 1) # NOTE: remaining time: -1 seconds
        expect(cache_store.read(entry[:key])).to eq(nil)
      end
    end
  end

  context 'when the required entry doesnt exist' do
    let(:nonexistent_entry) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

    it 'returns nil' do
      expect(cache_store.read(nonexistent_entry[:key])).to eq(nil)
    end
  end
end
