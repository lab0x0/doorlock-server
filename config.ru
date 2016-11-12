
require 'dotenv'
Dotenv.load

require "./app.rb"

run Sinatra::Application
