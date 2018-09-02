# frozen_string_literal: true

describe 'Operation: #decrement' do
  include_context 'cache store'

  let(:expiration_time) { 8 } # NOTE: in seconds
  let(:entry)           { { key: SecureRandom.hex, value: 1 } }

  shared_examples 'decrementation' do
    specify 'by default: increments by 1' do
      new_amount = cache_store.decrement(entry[:key])
      expect(new_amount).to eq(0)

      new_amount = cache_store.decrement(entry[:key])
      expect(new_amount).to eq(-1) | eq(0)

      new_amount = cache_store.decrement(entry[:key])
      expect(new_amount).to eq(-2) | eq(0)
    end

    specify 'returns new amount' do
      new_amount = cache_store.decrement(entry[:key], 1)
      expect(new_amount).to eq(0)

      new_amount = cache_store.decrement(entry[:key], 3)
      expect(new_amount).to eq(-3) | eq(0)

      new_amount = cache_store.decrement(entry[:key], 2)
      expect(new_amount).to eq(-5) | eq(0)
    end
  end

  context 'with previously defined temporal entry' do
    before { cache_store.write(entry[:key], entry[:value], expires_in: expiration_time) }

    it_behaves_like 'decrementation'

    context 'with re-expiration' do
      specify 'entry gets new expiration time' do
        cache_store.decrement(entry[:key], expires_in: expiration_time)
        sleep(4) # NOTE: remaining time: 4 seconds, current value: 0

        cache_store.decrement(entry[:key], 2, expires_in: expiration_time)
        sleep(4) # NOTE: remaining time: 4 seconds again, current value: -2

        expect(cache_store.read(entry[:key]).to_i).to eq(-2) | eq(0)
        sleep(5) # NOTE: remaining time: -1 seconds

        expect(cache_store.read(entry[:key])).to eq(nil)
      end
    end

    context 'without re-expiration' do
      specify 'entry dies when expiration time coming; creates new permanent entry' do
        cache_store.decrement(entry[:key], 2)
        sleep(expiration_time + 1) # NOTE: remaining time: -1 seconds, old value: -1; new: nothing

        new_amount = cache_store.decrement(entry[:key], 2)
        # NOTE: new amount: -2, old entry is dead, new entry is permanent
        expect(new_amount).to eq(-2) | eq(0)
        sleep(expiration_time + 1) # NOTE: remaining time: -1 esconds, current value: -2
        expect(cache_store.read(entry[:key]).to_i).to eq(-2) | eq(0)
      end
    end
  end

  context 'with previously defined permanent entry' do
    before { cache_store.write(entry[:key], entry[:value]) }

    it_behaves_like 'decrementation'

    context 'with re-expiration' do
      specify 'entry gets new expiration time' do
        cache_store.decrement(entry[:key], expires_in: expiration_time)
        sleep(4) # NOTE: remaining time: 4 seconds, current value: 0

        cache_store.decrement(entry[:key], 2, expires_in: expiration_time)
        sleep(4) # NOTE: remaining time: 4 seconds again, current value: -2

        expect(cache_store.read(entry[:key]).to_i).to eq(-2) | eq(0)
        sleep(5) # NOTE: remaining time: -1 seconds

        expect(cache_store.read(entry[:key])).to eq(nil)
      end
    end

    context 'without re-expiration' do
      it 'increases entry value' do
        new_amount = cache_store.decrement(entry[:key])
        expect(new_amount).to eq(0)

        new_amount = cache_store.decrement(entry[:key], 3)
        expect(new_amount).to eq(-3) | eq(0)

        sleep(expiration_time + 1)

        new_amount = cache_store.decrement(entry[:key], 5)
        expect(new_amount).to eq(-8) | eq(0)
      end
    end
  end

  context 'without previously defined entries' do
    context 'invocation with expiration' do
      it 'creates new temporal entry with corresponding initial value' do
        # NOTE: create new entry with a random initial value
        ini_value = rand(1..100)
        new_amount = cache_store.decrement(entry[:key], ini_value, expires_in: expiration_time)
        expect(new_amount).to eq(-ini_value) | eq(0)

        sleep(expiration_time + 1) # NOTE: expire current entry

        # NOTE: create new entry without initial value
        new_amount = cache_store.decrement(entry[:key], expires_in: expiration_time)
        expect(new_amount).to eq(-1) | eq(0)
      end
    end

    context 'invocation without expiration' do
      it 'creates new permanent entry with corresponding initial value' do
        ini_value = rand(1..100)
        new_amount = cache_store.decrement(entry[:key], ini_value)
        expect(new_amount).to eq(-ini_value) | eq(0)

        sleep(expiration_time + 1) # NOTE: try to expire current entry

        # NOTE: increase entry by default value
        new_amount = cache_store.decrement(entry[:key])
        expect(new_amount).to eq(-ini_value - 1) | eq(0)
      end
    end
  end
end
