# frozen_string_literal: true

describe 'Plugins ecosystem' do
  specify 'plguin regsitration, load and resolving' do
    # plugins are not registered
    expect(AnyCache::Plugins.names).not_to include('internal_test_plugin', 'external_test_plugin')
    expect(AnyCache.plugins).not_to        include('internal_test_plugin', 'external_test_plugin')

    InternalTestPluginInterceptor = Class.new { def self.invoke; end }
    ExternalTestPluginInterceptor = Class.new { def self.call; end }

    module AnyCache::Plugins
      class InternalTestPlugin < Abstract
        def self.load!
          InternalTestPluginInterceptor.invoke
        end
      end

      class ExternalTestPlugin < Abstract
        def self.load!
          ExternalTestPluginInterceptor.call
        end
      end

      # register new plugins
      register_plugin(:internal_test_plugin, InternalTestPlugin)
      register_plugin(:external_test_plugin, ExternalTestPlugin)
    end

    # plugins are registered
    expect(AnyCache::Plugins.names).to include('internal_test_plugin', 'external_test_plugin')
    expect(AnyCache.plugins).to        include('internal_test_plugin', 'external_test_plugin')

    # plugin can be loaded
    expect(InternalTestPluginInterceptor).to receive(:invoke).exactly(4).times
    AnyCache::Plugins.load(:internal_test_plugin)
    AnyCache::Plugins.load('internal_test_plugin')
    AnyCache.plugin(:internal_test_plugin)
    AnyCache.plugin('internal_test_plugin')

    # plugin can be loaded
    expect(ExternalTestPluginInterceptor).to receive(:call).exactly(4).times
    AnyCache::Plugins.load(:external_test_plugin)
    AnyCache::Plugins.load('external_test_plugin')
    AnyCache.plugin(:external_test_plugin)
    AnyCache.plugin('external_test_plugin')

    # fails when there is an attempt to register a plugin with already used name
    expect do
      module AnyCache::Plugins
        register_plugin(:internal_test_plugin, Object)
      end
    end.to raise_error(AnyCache::AlreadyRegisteredPluginError)

    # fails when there is an attempt to register a plugin with already used name
    expect do
      module AnyCache::Plugins
        register_plugin(:external_test_plugin, Object)
      end
    end.to raise_error(AnyCache::AlreadyRegisteredPluginError)

    # fails when there is an attempt to load an unregistered plugin
    expect do
      AnyCache::Plugins.load(:kek_test_plugin)
    end.to raise_error(AnyCache::UnregisteredPluginError)

    # fails when there is an attempt to load an unregistered plugin
    expect do
      AnyCache.plugin(:kek_test_plugin)
    end.to raise_error(AnyCache::UnregisteredPluginError)
  end
end
