source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem "blacklight", ">= 5.3.0"
gem "blacklight_range_limit"
gem "blacklight_advanced_search", github: 'projectblacklight/blacklight_advanced_search', branch: 'blacklight5'
# alternatively (better) use the path to your local gemfile so that you don't keep reading directly from github, ie., 
# gem "blacklight_advanced_search", :path => "gem "blacklight_advanced_search", :path => "/usr/local/lib/ruby/gems/1.9.1/gems/blacklight_advanced_search""

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem "devise"
gem "devise-guests", "~> 0.3"
gem "blacklight-marc", "~> 5.0"

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta'
end

