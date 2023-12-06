require "bundler/setup"
require "fb/jwt/auth"
require 'logger'
require 'simplecov'
require 'simplecov-console'

Time.zone = 'London'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

SimpleCov.start 'rails' do
  add_filter %w[
  bin
  tmp
]
  enable_coverage(:branch)
  enable_coverage_for_eval
end

SimpleCov.minimum_coverage 100
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
