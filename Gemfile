source 'http://rubygems.org'

gem 'rails', '3.1.10'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

group :production do
  gem 'pg'
end

gem 'therubyracer'          # missing javascript runtime
gem 'gravatar_image_tag'
gem 'will_paginate'
gem 'ruby-prof'
gem 'thin'

gem 'rb-readline' 

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
end

gem 'faker'
gem 'jquery-rails'

# Deploy with Capistrano
gem 'capistrano', '~> 2.12.0'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', '~> 0.8.3', :require => false
end