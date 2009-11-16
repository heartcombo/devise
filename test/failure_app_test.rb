require 'test/test_helper'
require 'ostruct' 

class FailureTest < ActiveSupport::TestCase

  def call_failure(env_params={})
    env = {'warden.options' => { :scope => :user }}.merge!(env_params)
    Devise::FailureApp.call(env)
  end

  test 'return 302 status' do
    assert_equal 302, call_failure.first
  end

  test 'return redirect location based on mapping with params' do
    assert_equal '/users/sign_in', call_failure.second['Location']
  end

  test 'uses the proxy failure message' do
    warden = OpenStruct.new(:message => :test)
    location = call_failure('warden' => warden).second['Location']
    assert_equal '/users/sign_in?test=true', location
  end

  test 'set content type to default text/plain' do
    assert_equal 'text/plain', call_failure.second['Content-Type']
  end

  test 'setup a default message' do
    assert_equal ['You are being redirected to /users/sign_in'], call_failure.last
  end
end
