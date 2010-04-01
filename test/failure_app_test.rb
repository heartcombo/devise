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
    Devise::FailureApp.call(env).to_a
  end

  def call_failure_with_http(env_params={})
    env = { "HTTP_AUTHORIZATION" => "Basic #{ActiveSupport::Base64.encode64("foo:bar")}" }
    call_failure(env_params.merge!(env))
  end

  context 'When redirecting' do
    test 'return 302 status' do
      assert_equal 302, call_failure.first
    end

    test 'return to the default redirect location' do
      assert_equal 'http://test.host/users/sign_in?unauthenticated=true', call_failure.second['Location']
    end

    test 'uses the proxy failure message as symbol' do
      warden = OpenStruct.new(:message => :test)
      location = call_failure('warden' => warden).second['Location']
      assert_equal 'http://test.host/users/sign_in?test=true', location
    end

    test 'uses the proxy failure message as string' do
      warden = OpenStruct.new(:message => 'Hello world')
      location = call_failure('warden' => warden).second['Location']
      assert_equal 'http://test.host/users/sign_in?message=Hello+world', location
    end

    test 'set content type to default text/html' do
      assert_equal 'text/html; charset=utf-8', call_failure.second['Content-Type']
    end

    test 'setup a default message' do
      assert_match /You are being/, call_failure.last.body
      assert_match /redirected/, call_failure.last.body
      assert_match /\?unauthenticated=true/, call_failure.last.body
    end
  end

  context 'For HTTP request' do
    test 'return 401 status' do
      assert_equal 401, call_failure_with_http.first
    end

    test 'return WWW-authenticate headers' do
      assert_equal 'Basic realm="Application"', call_failure_with_http.second["WWW-Authenticate"]
    end

    test 'uses the proxy failure message as response body' do
      warden = OpenStruct.new(:message => :invalid)
      response = call_failure_with_http('warden' => warden).third
      assert_equal 'Invalid email or password.', response.body
    end
  end

  context 'With recall' do
    test 'calls the original controller' do
      env = {
        "action_dispatch.request.parameters" => { :controller => "devise/sessions" },
        "warden.options" => { :recall => "new", :attempted_path => "/users/sign_in" },
        "warden" => stub_everything
      }
      response = call_failure(env).third
      assert response.body.include?('<h2>Sign in</h2>')
      assert response.body.include?('Invalid email or password.')
    end
  end
end
