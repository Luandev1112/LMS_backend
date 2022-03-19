source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0.0'
gem 'pg'
gem 'puma', '~> 3.11'
gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'rack-cors'
gem 'devise', '~> 4.0'
gem 'devise_lastseenable'
gem 'cancancan'
gem 'devise-jwt', '~> 0.8'
gem 'rolify'
gem 'awesome_print'
gem 'geokit-rails'
gem 'json-schema'
gem 'faker'
gem 'active_storage_base64'
gem 'jsonapi-resources', '0.9.11'
gem 'pry', '~> 0.13.1'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem "capistrano-bundler"
  gem "capistrano-passenger", '~> 0.2.0'
end

group :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'shoulda'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'timecop'
end