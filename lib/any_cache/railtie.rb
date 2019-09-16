# frozen_string_literal: true

class AnyCache
  class Railtie < ::Rails::Railtie
    config.before_configuration do
      config.cache_store = :any_cache_store
    end
  end
end
