# frozen_string_literal: true

describe 'raw read/write / non-raw read/write' do
  include_context 'cache store'

  before { stub_const('SimpleRubyObject', Struct.new(:a, :b, :c)) }

  specify 'non-raw is used by default' do
    ruby_object = SimpleRubyObject.new('a', 123, true)
    cache_store.write(:ruby_object, ruby_object)
    cached_ruby_object = cache_store.read(:ruby_object)

    expect(cached_ruby_object).to be_a(SimpleRubyObject)
    expect(cached_ruby_object).to have_attributes(a: 'a', b: 123, c: true)
  end

  context 'write non-raw (write real ruby object) (:raw => false)' do
    context 'single read/write' do
      specify '#read/#write works correctly' do
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
        expect(cached_another_ruby_object).to have_attributes(a: 1, b: 2, c: 3)
      end

      specify '#fetch works correctly' do
        returned_ruby_object = cache_store.fetch(:non_raw, raw: false) do |key|
          SimpleRubyObject.new(key, 1, false)
        end

        cached_ruby_object = cache_store.fetch(:non_raw, raw: false)

        [cached_ruby_object, returned_ruby_object].each do |cached_object|
          expect(cached_object).to be_a(SimpleRubyObject)
          expect(cached_object).to have_attributes(a: :non_raw, b: 1, c: false)
        end
      end
    end

    context 'multi read/write' do
      specify '#read_multi/#write_multi works correctly' do
        # worsk with any adequate type
        ruby_entries = {
          'hash_ruby_obj' => { a: 1, b: 2, c: 3 },
          'bool_ruby_obj' => true,
          'real_ruby_obj' => SimpleRubyObject.new(1, 2, 3)
        }

        cache_store.write_multi(ruby_entries, raw: false)
        cached_ruby_entries = cache_store.read_multi(*ruby_entries.keys, raw: false)

        expect(cached_ruby_entries).to match(ruby_entries)
      end

      specify '#fetch_multi works correctly' do
        returned_ruby_entries = cache_store.fetch_multi(:a, :b, :c, raw: false) do |key|
          SimpleRubyObject.new(key, 1, true)
        end

        cached_ruby_entries = cache_store.fetch_multi(:a, :b, :c, raw: false)

        [cached_ruby_entries, returned_ruby_entries].each do |cached_entries|
          expect(cached_entries[:a]).to be_a(SimpleRubyObject)
          expect(cached_entries[:b]).to be_a(SimpleRubyObject)
          expect(cached_entries[:c]).to be_a(SimpleRubyObject)

          expect(cached_entries[:a]).to have_attributes(a: :a, b: 1, c: true)
          expect(cached_entries[:b]).to have_attributes(a: :b, b: 1, c: true)
          expect(cached_entries[:c]).to have_attributes(a: :c, b: 1, c: true)
        end
      end
    end
  end

  # NOTE:
  #   ActiveSupport::Cache::FileStore and ActiveSupport::Cache::ReadStore does not support
  #   raw/non-raw optionality cuz under the hood these classes invokes #write_entry method
  #   that uses Marshal.dump before the write-to-disk and write-to-memory operations respectively.
  context(
    'write raw (:raw => true) (uses internal cache-related string-like object write operation)',
    exclude: %i[as_file_store as_memory_store]
  ) do

    before { stub_const('SimpleRubyObject', Struct.new(:a, :b, :c)) }

    context 'single read/write' do
      specify '#read/#write works correctly' do
        ruby_object = { a: 1, b: 2, c: 3}
        cache_store.write(:raw, ruby_object, raw: true)
        cached_ruby_object = cache_store.read(:raw, raw: true)

        expect(cached_ruby_object).to be_a(String)

        another_ruby_object = SimpleRubyObject.new(1, 2, 3)
        cache_store.write(:raw, another_ruby_object, raw: true)
        cached_another_ruby_object = cache_store.read(:raw, raw: true)

        expect(cached_another_ruby_object).to be_a(String)
      end

      specify '#fetch works correctly' do
        returned_ruby_object = cache_store.fetch(:raw, raw: true) do |key|
          SimpleRubyObject.new(key, 1, false)
        end

        cached_ruby_object = cache_store.fetch(:raw, raw: true)

        # TODO: think about consistent fetching
        #   - expect(returned_ruby_object).to be_a(String)
        #   - nonexistent value (first #fetch invokation)
        #     will return the &fallback's proc result (real ruby object)

        expect(cached_ruby_object).to be_a(String)
      end
    end

    context 'multi read/write' do
      specify '#read_multi/#write_multi works correctly' do
        # works with any adequate type
        ruby_entries = {
          'hash_ruby_obj' => { a: 1, b: 2, c: 3 },
          'bool_ruby_obj' => true,
          'real_ruby_obj' => SimpleRubyObject.new(1, 2, 3)
        }

        cache_store.write_multi(ruby_entries, raw: true)
        cached_ruby_entries = cache_store.read_multi(*ruby_entries.keys, raw: true)

        expect(cached_ruby_entries.keys).to contain_exactly(*ruby_entries.keys)
        expect(cached_ruby_entries.values).to all(be_a(String))
      end

      specify '#fetch_multi works correctly' do
        returned_ruby_entries = cache_store.fetch_multi(:a, :b, raw: true) do |key|
          SimpleRubyObject.new(key, true, false)
        end

        cached_ruby_entries = cache_store.fetch_multi(:a, :b, raw: true)

        # TODO: think about consistent fetching
        #   - expect(returned_ruby_entries.values).to all(be_a(String)) and so on
        #   - nonexistent value (first #fetch invokation)
        #     will return the &fallback's proc result (real ruby object)

        expect(cached_ruby_entries.keys).to contain_exactly(:a, :b)
        expect(cached_ruby_entries.values).to all(be_a(String))
      end
    end
  end
end
