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
  # it impossible to write tests for a custom strategy that uses a custom response with Devise.
  #
  # The code this test needs to verify is in Devise::TestHelpers#_catch_warden (which appears to have no other test
  # coverage at this point.)
  #
  # The functionality of this function should mirror Warden::Manager#call(env) and Warden::Manager#process_unauthenticated
  # which correctly detects the custom response when set by a strategy
  #
  class CustomStrategy < Warden::Strategies::Base
    cattr_accessor :active

    def authenticate!
      custom_headers = { "X-FOO" => "BAR" }
      response = Rack::Response.new("BAD REQUEST", 400, custom_headers)
      custom! response.finish
    end

    def valid?
      self.active
    end

    self.active = false

    def self.with_active(&block)
      begin
        self.active = true
        resp = yield
      ensure
        self.active = false
      end
      resp
    end
  end



  def setup
    @controller.request.env['devise.mapping'] = Devise.mappings[:user]
  end


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
        #'warden' => OpenStruct.new(:message => nil)
    })
    request.env.merge!(env_params)

    strategy = CustomStrategy.new request.env, :user

    # processing a test request eventually calls _catch_warden:
    _catch_warden do
      # when a controller action is triggered, its before filter would require authentication. Devise uses
      # warden to execute the strategies. Skip to:
      strategy.authenticate!

      # TODO: check if we need to simulate any other part of the response...?

      # after the strategy executes, halt! has been called (from in custom!) above which eventually results in
      # the :warden symbol being thrown
      throw :warden
    end

    # after this point, @response should be set to the custom response when triggered by a custom strategy, or
    # the response of the FailureApp as normal.
    response
  end


  test "custom strategy can return its own status code" do
    CustomStrategy.with_active do
      call_custom
    end

    assert @reponse.is_a?(Array)
    assert_equal 400, @response.first

  end

end
