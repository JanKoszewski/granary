source 'https://rubygems.org'

gem 'rails', '3.2.6'
gem 'jquery-rails'
gem 'jbuilder'

platforms :jruby do
  # gem 'activerecord-jdbc-adapter', :require => false
  gem 'trinidad'
  gem 'neo4j', "~> 2.0"
end

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'capistrano'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem "rack-test", require: "rack/test"
  gem 'guard'
  gem 'guard-jruby-rspec'
end
