require 'rubygems'
require 'bundler'

Bundler.require

configure :development do
  require 'dotenv'
  Dotenv.load
end

configure :test do
  require 'dotenv'
  Dotenv.load
end

configure :production do
  require 'newrelic_rpm'
end

require './movieingon'
run MovieingOn
