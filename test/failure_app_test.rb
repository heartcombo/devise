require 'test_helper'
require 'ostruct'

class FailureTest < ActiveSupport::TestCase
  def self.context(name, &block)
    instance_eval(&block)
  end

  def call_failure(env_params={})
    env = {
      'warden.options' => { :scope => :user },
      'REQUEST_URI' => 'http://test.host/',
      'HTTP_HOST' => 'test.host',
      'REQUEST_METHOD' => 'GET',
      'rack.session' => {},
      'rack.input' => "",
      'warden' => OpenStruct.new(:message => nil)
    }.merge!(env_params)
    
    @response = Devise::FailureApp.call(env).to_a
    @request  = ActionDispatch::Request.new(env)
  end

  def call_failure_with_http(env_params={})
    env = { "HTTP_AUTHORIZATION" => "Basic #{ActiveSupport::Base64.encode64("foo:bar")}" }
    call_failure(env_params.merge!(env))
  end

  context 'When redirecting' do
    test 'return 302 status' do
      call_failure
      assert_equal 302, @response.first
    end

    test 'return to the default redirect location' do
      call_failure
      assert_equal 'You need to sign in or sign up before continuing.', @request.flash[:alert]
      assert_equal 'http://test.host/users/sign_in', @response.second['Location']
    end

    test 'uses the proxy failure message as symbol' do
      call_failure('warden' => OpenStruct.new(:message => :test))
      assert_equal 'test', @request.flash[:alert]
      assert_equal 'http://test.host/users/sign_in', @response.second["Location"]
    end

    test 'uses the proxy failure message as string' do
      call_failure('warden' => OpenStruct.new(:message => 'Hello world'))
      assert_equal 'Hello world', @request.flash[:alert]
      assert_equal 'http://test.host/users/sign_in', @response.second["Location"]
    end

    test 'set content type to default text/html' do
      call_failure
      assert_equal 'text/html; charset=utf-8', @response.second['Content-Type']
    end

    test 'setup a default message' do
      call_failure
      assert_match /You are being/, @response.last.body
      assert_match /redirected/, @response.last.body
      assert_match /users\/sign_in/, @response.last.body
    end
  end

  context 'For HTTP request' do
    test 'return 401 status' do
      call_failure_with_http
      assert_equal 401, @response.first
    end

    test 'return WWW-authenticate headers' do
      call_failure_with_http
      assert_equal 'Basic realm="Application"', @response.second["WWW-Authenticate"]
    end

    test 'uses the proxy failure message as response body' do
      call_failure_with_http('warden' => OpenStruct.new(:message => :invalid))
      assert_equal 'Invalid email or password.', @response.third.body
    end
  end

  context 'With recall' do
    test 'calls the original controller' do
      env = {
        "action_dispatch.request.parameters" => { :controller => "devise/sessions" },
        "warden.options" => { :recall => "new", :attempted_path => "/users/sign_in" },
        "warden" => stub_everything
      }
      call_failure(env)
      assert @response.third.body.include?('<h2>Sign in</h2>')
      assert @response.third.body.include?('Invalid email or password.')
    end
  end
end
