# frozen_string_literal: true

describe 'Feature: Logging' do
  include_context 'cache store'

  let(:output) { StringIO.new }
  let(:logger) { ::Logger.new(output).tap { |logger| logger.level = ::Logger::INFO } }

  describe 'logger settings' do
    let(:log_levels) do
      [
        { level: ::Logger::INFO,    flag: 'INFO'  },
        { level: ::Logger::WARN,    flag: 'WARN'  },
        { level: ::Logger::ERROR,   flag: 'ERROR' },
        { level: ::Logger::FATAL,   flag: 'FATAL' },
        { level: ::Logger::UNKNOWN, flag: 'ANY'   }
      ]
    end

    specify 'logging works with logger\'s pre-configured level' do
      log_levels.each do |log_level|
        output = StringIO.new
        logger = ::Logger.new(output).tap { |lggr| lggr.level = log_level[:level] }
        cache_store.shared_config.configure { |conf| conf.logger = logger }

        expect(output.string).not_to include(" #{log_level[:flag]} -- ")
        cache_store.clear
        expect(output.string).to include(" #{log_level[:flag]} -- ")
      end
    end
  end

  describe 'operation logging' do
    before { cache_store.shared_config.configure { |conf| conf.logger = logger } }

    let(:entry) { { key: SecureRandom.hex, value: SecureRandom.hex(4) } }
    let(:expires_in) { 8 }
    let(:cacher_name) { cache_store.class.name }

    specify '#read' do
      cache_store.read(entry[:key], { custom_option: SecureRandom.hex(4) })
      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<read>]")
    end

    specify '#write' do
      cache_store.write(entry[:key], entry[:value], { expires_in: expires_in })
      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<write>]")
    end

    specify '#delete' do
      cache_store.delete(entry[:key], { custom_option: SecureRandom.hex(4) })
      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<delete>]")
    end

    specify '#increment' do
      cache_store.write(entry[:key], rand(2..10))
      cache_store.increment(entry[:key], rand(1..2), { expires_in: expires_in })
      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<increment>]")
    end

    specify '#decrmenet' do
      cache_store.write(entry[:key], rand(2..10))
      cache_store.decrement(entry[:key], rand(1..2), expires_in: expires_in)
      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<decrement>]")
    end

    specify '#expire' do
      cache_store.write(entry[:key], entry[:value])
      cache_store.expire(entry[:key], expires_in: expires_in)
      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<expire>]")
    end

    specify '#persist' do
      cache_store.write(entry[:key], entry[:value], expires_in: expires_in)
      cache_store.persist(entry[:key])
      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<persist>]")
    end

    specify '#clear' do
      cache_store.clear(custom_option: SecureRandom.hex(4))
      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<clear>]")
    end

    specify '#exist?' do
      cache_store.exist?(entry[:key], custom_option: SecureRandom.hex(4))
      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<exist?>]")
    end

    specify '#fetch' do
      cache_store.fetch(entry[:key], force: [true, false].sample, expires_in: expires_in) do
        entry[:value]
      end

      expect(output.string).to include("[AnyCache<#{cacher_name}>/Activity<fetch>]")
    end
  end
end
