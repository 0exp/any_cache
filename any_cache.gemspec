# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'any_cache/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.3.8'

  spec.name          = 'any_cache'
  spec.version       = AnyCache::VERSION
  spec.authors       = ['Rustam Ibragimov']
  spec.email         = ['iamdaiver@icloud.com']

  spec.summary       = 'AnyCache - a simplest cache wrapper'
  spec.description   = 'AnyCache - a simplest cache wrapper that provides ' \
                       'a minimalistic generic interface for the all well-known ' \
                       'cache storages and includes a minimal set of necessary operations.'

  spec.homepage      = 'https://github.com/0exp/any_cache'
  spec.license       = 'MIT'
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  end

  spec.add_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_dependency 'qonfig',          '~> 0.7'

  spec.add_development_dependency 'coveralls',        '~> 0.8'
  spec.add_development_dependency 'simplecov',        '~> 0.16'
  spec.add_development_dependency 'armitage-rubocop', '~> 0.10'
  spec.add_development_dependency 'rspec',            '~> 3.8'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
end
