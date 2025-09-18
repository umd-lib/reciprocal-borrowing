source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
# Use Puma as the app server
gem "puma", ">= 5.0"
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Add Bootstrap
gem 'bootstrap-sass', '3.3.6'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# dotenv - For storing production configuration parameters
gem 'dotenv-rails', '~> 2.7.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :test do
  gem 'minitest-reporters', '~> 1.1.8'
  gem 'minitest-ci', '~> 3.0.3'

  # Code analysis tools
  gem 'rubocop', '= 1.55.0', require: false
  gem 'rubocop-rails', '= 2.20.2', require: false
  gem 'rubocop-checkstyle_formatter', '~> 0.2.0', require: false
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
end

# UMD Customization
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
