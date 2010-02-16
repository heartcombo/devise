require 'test/test_helper'
require 'ostruct'

class FailureTest < ActiveSupport::TestCase

  def call_failure(env_params={})
    env = {
      'warden.options' => { :scope => :user },
      'REQUEST_URI' => 'http://test.host/',
      'REQUEST_METHOD' => 'GET',
      'rack.session' => {}
    }.merge!(env_params)
    Devise::FailureApp.call(env)
  end

  test 'return 302 status' do
    assert_equal 302, call_failure.first
  end

  test 'return to the default redirect location' do
    assert_equal '/users/sign_in?unauthenticated=true', call_failure.second['Location']
  end

  test 'uses the proxy failure message' do
    warden = OpenStruct.new(:message => :test)
    location = call_failure('warden' => warden).second['Location']
    assert_equal '/users/sign_in?test=true', location
  end

  test 'uses the given message' do
    warden = OpenStruct.new(:message => 'Hello world')
    location = call_failure('warden' => warden).second['Location']
    assert_equal '/users/sign_in?message=Hello+world', location
  end

  test 'setup default url' do
    Devise::FailureApp.default_url = 'test/sign_in'
    location = call_failure('warden.options' => { :scope => nil }).second['Location']
    assert_equal '/test/sign_in?unauthenticated=true', location
  end

  test 'set content type to default text/plain' do
    assert_equal 'text/plain', call_failure.second['Content-Type']
  end

  test 'setup a default message' do
    assert_equal ['You are being redirected to /users/sign_in?unauthenticated=true'], call_failure.last
  end
end
