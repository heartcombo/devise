require 'test/test_helper'

class FailureTest < ActiveSupport::TestCase

  def call_failure(env_params={})
    env = {'warden.options' => {:scope => :user}.update(env_params)}
    Devise::Failure.call(env)
  end

  test 'return 302 status' do
    assert_equal 302, call_failure.first
  end

  test 'return redirect location based on mapping with params' do
    assert_equal '/users/sign_in', call_failure.second['Location']
  end

  test 'add params to redirect location' do
    location = call_failure(:params => {:test => true}).second['Location']
    assert_equal '/users/sign_in?test=true', location
  end

  test 'set content type to default text/plain' do
    assert_equal 'text/plain', call_failure.second['Content-Type']
  end

  test 'setup a default message' do
    assert_equal ['You are being redirected to /users/sign_in'], call_failure.last
  end

  test 'pass in a different message' do
    assert_equal ['Hello world'], call_failure(:message => 'Hello world').last
  end
end
