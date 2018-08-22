# frozen_string_literal: true

module SpecSupport::Cache::ActiveSupportFileStore
  include Qonfig::Configurable

  configuration do
    setting :file_path, File.expand_path(
      File.join('..', '..', 'artifacts', SecureRandom.hex),
      Pathname.new(__FILE__).realpath
    )
  end

  class << self
    def load_dependencies!
      require 'active_support'
    end

    def connect
      load_dependencies!

      ::ActiveSupport::Cache::FileStore.new(config[:file_path])
    end
  end
end
