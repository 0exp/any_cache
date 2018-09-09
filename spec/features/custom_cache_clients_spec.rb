# frozen_string_literal: true

describe 'Custom cache clients' do
  context 'when custom cache clinet supports all required methods' do
    let(:custom_client) do
      Class.new do
        # rubocop:disable Layout/EmptyLineBetweenDefs
        def read(key, **); end
        def read_multi(*keys, **); end
        def write(key, value, **); end
        def write_multi(entries, **); end
        def delete(key, **); end
        def increment(key, value, **); end
        def decrement(key, value, **); end
        def expire(key, **); end
        def persist(key, **); end
        def clear(key, **); end
        def exist?(key, **); end
        def fetch(key, **); end
        # rubocop:enable Layout/EmptyLineBetweenDefs
      end.new
    end

    let(:dumb_client) do
      # rubocop:disable Layout/EmptyLineBetweenDefs
      Class.new do
        def read; end
        def read_multi; end
        def write; end
        def write_multi; end
        def delete; end
        def increment; end
        def decrement; end
        def expire; end
        def persist; end
        def clear; end
        def exist?; end
        def fetch; end
      end.new
      # rubocop:enable Layout/EmptyLineBetweenDefs
    end

    specify 'returns AnyCache instance' do
      expect(AnyCache.build(custom_client)).to be_a(AnyCache)
    end

    specify 'requires only a delegation' do
      expect(AnyCache.build(dumb_client)).to be_a(AnyCache)
    end

    %i[
      read
      read_multi
      delete
      expire
      persist
      clear
      fetch
      exist?
    ].each do |operation|
      specify "AnyCache instance delegates :#{operation} operation to the custom client" do
        cache_store = AnyCache.build(custom_client)

        entry_key      = SecureRandom.hex
        method_options = { SecureRandom.hex.to_sym => SecureRandom.hex(4) }

        expect(custom_client).to receive(operation).with(entry_key, method_options)
        cache_store.send(operation, entry_key, **method_options)
      end
    end

    %i[
      write
      increment
      decrement
    ].each do |operation|
      specify "AnyCache instance delegates :#{operation} operation to the custom client" do
        cache_store = AnyCache.build(custom_client)

        entry_key      = SecureRandom.hex
        method_value   = SecureRandom.hex
        method_options = { SecureRandom.hex.to_sym => SecureRandom.hex(4) }

        expect(custom_client).to receive(operation).with(entry_key, method_value, method_options)
        cache_store.send(operation, entry_key, method_value, **method_options)
      end
    end

    %i[
      write_multi
    ].each do |operation|
      specify "anyCache instance delegates :#{operation} operation to the custom client" do
        cache_store = AnyCache.build(custom_client)

        entries = {
          SecureRandom.hex => SecureRandom.hex(4),
          SecureRandom.hex => SecureRandom.hex(4),
          SecureRandom.hex => SecureRandom.hex(4)
        }

        method_options = { SecureRandom.hex.to_sym => SecureRandom.hex }

        expect(custom_client).to receive(operation).with(entries, method_options)
        cache_store.send(operation, entries, **method_options)
      end
    end
  end

  context 'when custom cache client supports a part of required methods' do
    let(:required_methods) do
      %i[
        read
        read_multi
        write
        write_multi
        delete
        increment
        decrement
        expire
        persist
        clear
        fetch
        exist?
      ]
    end

    specify 'fails due to instantiation' do
      while required_methods.shift
        incomplete_cache_client = Class.new.tap do |klass|
          required_methods.each do |required_method|
            klass.send(:define_method, required_method, &(proc {}))
          end
        end.new

        expect do
          AnyCache.build(incomplete_cache_client)
        end.to raise_error(AnyCache::UnsupportedDriverError)
      end
    end
  end
end
