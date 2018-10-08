source 'https://rubygems.org'

ruby "2.3.3"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Rails i18n
gem 'rails-i18n', '~> 5.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Devise authentication
gem 'devise', '~> 4.3.0'
# Devise i18n
gem 'devise-i18n', '~> 1.2.0'
# Pundit authorization
gem 'pundit', '~> 1.1.0'
# ActiveAdmin dashboard
gem 'activeadmin', github: 'activeadmin', tag: 'v1.1.0'
gem 'formadmin', git: 'https://github.com/formaweb/formadmin.git', tag: 'v0.2.1'
# Extensions of ActiveAdmin
gem 'just-datetime-picker', '~> 0.0.7'

# Validate datetimes
gem 'validates_timeliness', '~> 4.0.2'
# Validate urls
gem 'validate_url', '~> 1.0.2'

# Upload handling
gem 'carrierwave', '~> 1.1.0'

# Notify exceptions by e-mail
gem 'exception_notification', '~> 4.2.2'

# Background jobs with ActiveJobs + Que
gem 'que', '~> 0.14.0'
gem 'sinatra', '~> 2.0.0'
gem 'que-web', '~> 0.5.0'

# Locking on PostgreSQL
gem 'with_advisory_lock', '~> 3.1.1'

# Import CSV files
gem 'smarter_csv', '~> 1.1.4'

# Mailgun
gem 'mailgun-ruby', '~> 1.1.8'

# Export XLS files
gem 'spreadsheet', '~> 1.1.4'

# Markdown support
gem 'redcarpet', '~> 3.4.0'

# GPG
gem 'mail-gpg', '~> 0.3.1'
gem 'gpgme', '~> 2.0.14'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  # Testing gems
  gem 'factory_girl', '~> 4.8.0'
  gem 'rspec-rails', '~> 3.6.0'
  gem 'faker', '~> 1.8.4'
  gem 'ffaker', '~> 2.7.0'
  gem 'shoulda-matchers', '~> 3.1.2'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
