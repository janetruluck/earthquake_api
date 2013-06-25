require 'simplecov'
SimpleCov.start "rails"
# spec/spec_helper.rb
require File.join(File.dirname(__FILE__), '..', 'app.rb')
require 'sinatra'
require 'rack/test'
require 'webmock/rspec'
require 'database_cleaner'
require 'factory_girl'
require 'resque_spec'
require 'vcr'
# Require factories
Dir[File.dirname(__FILE__)+"/factories/*.rb"].each {|file| require file }

# setup test environment
ENV['RACK_ENV'] = 'test'
set :environment, :test
set :run, false
set :raise_errors, false
set :logging, false

# Supress Active Record Logging
old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

def app
  Sinatra::Application
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Rack::Test::Methods
  config.color_enabled = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
