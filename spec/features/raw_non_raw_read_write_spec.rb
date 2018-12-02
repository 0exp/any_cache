# frozen_string_literal: true

describe 'raw read/write / non-raw read/write', :focus do
  include_context 'cache store'

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
    context 'single read/write' do
      specify 'writes real ruby object' do
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

    context 'multi read/write' do
      specify 'writes real ruby object' do
        # worsk with any adequate type
        ruby_entries = {
          hash_ruby_obj: { a: 1, b: 2, c: 3 },
          bool_ruby_obj: true,
          real_ruby_obj: SimpleRubyObject.new(1, 2, 3)
        }

        cache_store.write_multi(ruby_entries, raw: false)
        cached_ruby_entries = cache_store.read_multi(*ruby_entries.keys, raw: false)

        expect(cached_ruby_entries).to match(ruby_entries)
      end
    end
  end

  # NOTE:
  #   ActiveSupport::Cache::FileStore and ActiveSupport::Cache::ReadStore does not support
  #   raw/non-raw optionality cuz under the hood these classes invokes #write_entry method
  #   that uses Marshal.dump before the write-to-disk and write-to-memory operations respectively.
  context 'write raw (:raw option is true)', exclude: %i[as_file_store as_memory_store] do
    before { stub_const('SimpleRubyObject', Struct.new(:a, :b, :c)) }

    context 'single read/write' do
      specify 'uses internal cache-related string-like object write operation' do
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

    context 'multi read/write' do
      specify 'uses internal cache-related string-like object write operation' do
        # works with any adequate type
        ruby_entries = {
          hash_ruby_obj: { a: 1, b: 2, c: 3 },
          bool_ruby_obj: true,
          real_ruby_obj: SimpleRubyObject.new(1, 2, 3)
        }

        cache_store.write_multi(ruby_entries, raw: true)
        cached_ruby_entries = cache_store.read_multi(*ruby_entries.keys, raw: true)

        expect(cached_ruby_entries.keys).to contain_exactly(*ruby_entries.keys)
        expect(cached_ruby_entries.values).to all(be_a(String))
      end
    end
  end
end
