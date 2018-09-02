# frozen_string_literal: true

shared_context 'cache store' do
  after { cache_store.clear }

  let(:cache_store) { build_cache_store }
end
