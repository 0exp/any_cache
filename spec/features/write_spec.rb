# frozen_string_literal: true

describe 'Operation: #write' do
  include_context 'cache store'

  let(:expiration_time) { 8 } # NOTE: in seconds
  let(:first_pair)      { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
  let(:second_pair)     { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }

  describe 'raw write / non-raw write' do
    before { stub_const('SimpleRubyObject', Struct.new(:a, :b, :c)) }

    specify 'non-raw is used by default' do
      ruby_object = SimpleRubyObject.new('a', 123, true)
      cache_store.write(:ruby_object, ruby_object)
      cached_ruby_object = cache_store.read(:ruby_object)

      expect(cached_ruby_object).to be_a(SimpleRubyObject)
      expect(cached_ruby_object.a).to eq('a')
      expect(cached_ruby_object.b).to eq(123)
      expect(cached_ruby_object.c).to eq(true)
    end

    context 'write non-raw (:raw option is false)' do
      specify 'returns real ruby object' do
        # works with initial structures
        ruby_object = { a: 1, b: 2, c: 3 }
        cache_store.write(:non_raw, ruby_object, raw: false)
        cached_ruby_object = cache_store.read(:non_raw, raw: false)

        expect(cached_ruby_object).to be_a(Hash)
        expect(cached_ruby_object).to match(ruby_object)

        # works with custom classes
        another_ruby_object = SimpleRubyObject.new(1, 2, 3)
        cache_store.write(:non_raw, another_ruby_object, raw: false)
        cached_another_ruby_object = cache_store.read(:non_raw, raw: false)

        expect(cached_another_ruby_object).to be_a(SimpleRubyObject)
        expect(cached_another_ruby_object.a).to eq(1)
        expect(cached_another_ruby_object.b).to eq(2)
        expect(cached_another_ruby_object.c).to eq(3)
      end
    end

    context 'write raw (:raw option is true)' do
      before { stub_const('SimpleRubyObject', Struct.new(:a, :b, :c)) }

      # NOTE:
      #   ActiveSupport::Cache::FileStore and ActiveSupport::Cache::ReadStore does not support
      #   :raw optionality cuz under the hood these classes invokes #write_entry method that uses
      #   Marshal.dump before the write-to-disk and write-to-memory operations respectively.
      specify(
        'returns internal cache-related string-like object',
        exclude: %i[as_file_store as_memory_store]
      ) do
        ruby_object = { a: 1, b: 2, c: 3}
        cache_store.write(:raw, ruby_object, raw: true)
        cached_ruby_object = cache_store.read(:raw, raw: true)

        expect(cached_ruby_object).to be_a(String)

        another_ruby_object = SimpleRubyObject.new(1, 2, 3)
        cache_store.write(:raw, another_ruby_object, raw: true)
        cached_another_ruby_object = cache_store.read(:raw, raw: true)

        expect(cached_another_ruby_object).to be_a(String)
      end
    end
  end

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
