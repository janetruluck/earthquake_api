require "./app.rb"
require "resque/server"

run Rack::URLMap.new \
  "/"       => Sinatra::Application, # Mount Sinatra App at /
  "/resque" => Resque::Server.new    # Mount resque-web at /resque

