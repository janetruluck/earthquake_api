require "./app"
require "resque/tasks"
require "sinatra/activerecord/rake"

namespace :resque do
  task :setup do
    ENV['QUEUE'] = '*'
  end
end