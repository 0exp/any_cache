# frozen_string_literal: true

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.minimum_coverage(100)
SimpleCov.start do
  enable_coverage :branch
  add_filter 'spec'
end

require 'bundler/setup'
require 'any_cache'
require 'pry'

require_relative 'support/spec_support'
require_relative 'support/shared_contexts'

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random
  Kernel.srand config.seed

  config.include SpecSupport::Helpers
  config.include SpecSupport::Testing
  config.extend  SpecSupport::Testing
end
