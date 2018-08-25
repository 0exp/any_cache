# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop'
require 'rubocop-rspec'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = %w[--config ./.rubocop.yml]
  t.requires << 'rubocop-rspec'
end

RSpec::Core::RakeTask.new(:rspec)

task default: :rspec
