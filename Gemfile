source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# UMD Customization
# dotenv - For storing production configuration parameters
gem 'dotenv-rails', '~> 2.7.0'
# End UMD Customization

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

# UMD Customization
group :test do
  gem 'minitest-reporters', '~> 1.1.8'
  gem 'minitest-ci', '~> 3.0.3'

  # Code coverage tools
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
end

# The following gems need to be "pinned" to specific versions because they
# are "default" gems provided by Ruby 3.2.2.
#
# Without "pinning" these gem versions, Passenger Phusion will complain
# about a version mismatch.
#
# This customization should be re-visited when upgrading to a later version
# of Ruby.
gem 'base64', '= 0.1.1'
gem 'logger', '= 1.5.3'
# End UMD Customization
