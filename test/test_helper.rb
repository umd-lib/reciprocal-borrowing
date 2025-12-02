# UMD Customizatiom
require "simplecov"
require "simplecov-rcov"
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start
# End UMD Customizatiom

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# UMD Customizatiom
require "minitest/reporters"
Minitest::Reporters.use!
# End UMD Customizatiom

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Add more helper methods to be used by all tests here...
  end
end
