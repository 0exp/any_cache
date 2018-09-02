# frozen_string_literal: true

describe 'Operation: #write' do
  include_context 'cache store'

  let(:expiration_time) { 8 } # NOTE: in seconds
  let(:first_pair)      { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:second_pair)     { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

  context 'without expiration' do
    it 'writes permanent entry' do
      # NOTE: permanent entries
      cache_store.write(first_pair[:key], first_pair[:value])
      cache_store.write(second_pair[:key], second_pair[:value])

      expect(cache_store.read(first_pair[:key])).to eq(first_pair[:value])
      expect(cache_store.read(second_pair[:key])).to eq(second_pair[:value])

      sleep(expiration_time) # NOTE: remaining time: 0 seconds

      # NOTE: all entries alive
      expect(cache_store.read(first_pair[:key])).to eq(first_pair[:value])
      expect(cache_store.read(second_pair[:key])).to eq(second_pair[:value])
    end
  end

  context 'with expiration' do
    it 'writes temporal entry' do
      # NOTE: temporal entry
      cache_store.write(first_pair[:key], first_pair[:value], expires_in: expiration_time)

      # NOTE: permanent entry
      cache_store.write(second_pair[:key], second_pair[:value])

      expect(cache_store.read(first_pair[:key])).to eq(first_pair[:value])
      expect(cache_store.read(second_pair[:key])).to eq(second_pair[:value])

      sleep(expiration_time + 1)

      # NOTE: temporal entry is dead
      expect(cache_store.read(first_pair[:key])).to eq(nil)
      # NOTE: permanent entry is alive
      expect(cache_store.read(second_pair[:key])).to eq(second_pair[:value])
    end
  end
end
