# frozen_string_literal: true

describe 'Operation: #expire', :focus do
  after { cache_store.clear }

  let(:cache_store)  { build_cache_store }
  let(:first_entry)  { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:second_entry) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

  context 'invokation with expiration attribute' do
    it 'changes expiration time of entry' do
      # NOTE: remaining time: 8 seconds
      cache_store.write(first_entry[:key], first_entry[:value], expires_in: 8)
      # NOTE: permanent entry
      cache_store.write(second_entry[:key], second_entry[:value])

      # NOTE: remaining time: 4 seconds
      sleep(4)

      # NOTE: remaining time: 8 seconds again
      cache_store.expire(first_entry[:key], expires_in: 8)

      # NOTE: remaining time: 4 seconds
      sleep(4)

      # NOTE: first_entry is alive
      expect(cache_store.read(first_entry[:key])).to eq(first_entry[:value])
      # NOTE: second entry is alive
      expect(cache_store.read(second_entry[:key])).to eq(second_entry[:value])

      # NOTE: remaining time: -1 second
      sleep(5)

      # NOTE: first_entry is dead
      expect(cache_store.read(first_entry[:key])).to eq(nil)
      # NOTE: second entry is elive
      expect(cache_store.read(second_entry[:key])).to eq(second_entry[:value])
    end
  end

  context 'invokation without expiration attribute' do
    it 'expires entry immedietly' do
      # NOTE: remaining time: 15 seconds
      cache_store.write(first_entry[:key], first_entry[:value], expires_in: 15)
      # NOTE: permanent entry
      cache_store.write(second_entry[:key], second_entry[:value])

      # NOTE: expire first_entry immedietly
      cache_store.expire(first_entry[:key])

      # NOTE: first_entry is dead
      expect(cache_store.read(first_entry[:key])).to eq(nil)
      # NOTE: second_entry is alive
      expect(cache_store.read(second_entry[:key])).to eq(second_entry[:value])
    end
  end
end
