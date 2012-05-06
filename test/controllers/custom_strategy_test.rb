require 'test_helper'
require 'ostruct'
require 'warden/strategies/base'
require 'devise/test_helpers'

class MyController < DeviseController
end

class CustomStrategyTest < ActionController::TestCase
  tests MyController

  include Devise::TestHelpers

  # These tests are to prove that a warden strategy can successfully return a custom response, including a specific
  # status code and custom http response headers. This does work in production, however, at the time of writing this,
  # the Devise test helpers do not recognise the custom response and proceed to calling the Failure App. This makes
  # it impossible to write tests for a strategy that return a custom response with Devise.
  #
  # The code this test needs to verify is in Devise::TestHelpers#_catch_warden (which appears to have no other test
  # coverage at this point.) The functionality of this function should mirror Warden::Manager#call(env) and
  # Warden::Manager#process_unauthenticated which correctly detects the custom response when set by a strategy.
  #
  class CustomStrategy < Warden::Strategies::Base
    def authenticate!
      custom_headers = { "X-FOO" => "BAR" }
      response = Rack::Response.new("BAD REQUEST", 400, custom_headers)
      custom! response.finish
    end
  end

  # call the custom strategy, returning the rack result array
  def call_custom(env_params={})
    request.env ||= {}
    request.env.merge! ({
        'REQUEST_URI' => 'http://test.host/',
        'HTTP_HOST' => 'test.host',
        'REQUEST_METHOD' => 'GET',
        'warden.options' => { :scope => :user },
        'rack.session' => {},
        'action_dispatch.request.formats' => Array(env_params.delete('formats') || Mime::HTML),
        'rack.input' => "",
    })
    request.env.merge!(env_params)
    env = request.env

    # create a strategy instance
    strategy = CustomStrategy.new env, :user

    # processing a test request eventually calls _catch_warden:
    ret = _catch_warden do

      # when a controller action is triggered, its before filter would require authentication. Devise uses
      # warden to execute the strategies.

      # simulate its selection as the winning strategy (the custom response is read from .winning_strategy)
      warden.winning_strategy = strategy

      # And then the strategy is executed:
      strategy.authenticate!

      # after the strategy executes, halt! has been called (from in custom!) above which eventually results in
      # the :warden symbol being thrown, which is caught in Devise::TestHelpers#_catch_warden
      throw :warden
    end

    # after this point, @response should be set to the custom response when triggered by a custom strategy, or
    # the response of the FailureApp as normal.
    ret
  end


  test "custom strategy can return its own status code" do
    ret = call_custom

    # check the returned rack array
    assert ret.is_a?(Array)
    assert_equal 400, ret.first

    # check the saved response as well:
    assert_response 400

  end

  test "custom strategy can return custom headers" do
    ret = call_custom

    # check the returned rack array
    assert ret.is_a?(Array)
    assert_equal ret.third['X-FOO'], 'BAR'

    # check the saved response as well:
    assert_equal response.headers['X-FOO'], 'BAR'
  end

end
