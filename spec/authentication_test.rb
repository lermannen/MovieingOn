ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require 'dotenv'
Dotenv.load

require_relative 'movieingon'

class ApplicationTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    MovieingOn
  end

  def test_without_authentication
    get '/admin'
    assert_equal 401, last_response.status
  end

  def test_with_bad_credentials
    authorize 'bad', 'boy'
    get '/admin'
    assert_equal 401, last_response.status
  end

  def test_with_proper_credentials
    authorize 'admin', '7qxbxwm4tDjT4T'
    get '/admin'
    assert_equal 200, last_response.status
    #assert_equal "You're welcome", last_response.body
  end
end