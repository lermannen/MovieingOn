ENV['RACK_ENV'] = 'test'

require 'dotenv'
Dotenv.load

require "spec_helper"
require "db"
require "rack/test"

require_relative "../movieingon"

module DbSpecHelpers
  attr_accessor :db
end

module RackSpecHelpers
  include Rack::Test::Methods
  attr_accessor :app
end

RSpec.configure do |config|
	config.include DbSpecHelpers, feature: true
  config.before feature: true do
    self.db = ::DB
  end

  config.include RackSpecHelpers, feature: true
  config.before feature: true do
    self.app = MovieingOn
  end
end