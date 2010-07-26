require 'test_helper'

class OauthRoutesTest < ActionController::TestCase
  tests ApplicationController

  def assert_path_and_url(action, provider)
    # Resource param
    assert_equal @controller.send(action, :user, provider),
                 @controller.send("user_#{action}", provider)

    # Default url params
    assert_equal @controller.send(action, :user, provider, :param => 123),
                 @controller.send("user_#{action}", provider, :param => 123)

    # With an object
    assert_equal @controller.send(action, User.new, provider, :param => 123),
                 @controller.send("user_#{action}", provider, :param => 123)
  end

  test 'should alias oauth_callback to mapped user auth_callback' do
    assert_path_and_url :oauth_callback_path, :github
    assert_path_and_url :oauth_callback_url,  :github
    assert_path_and_url :oauth_callback_path, :facebook
    assert_path_and_url :oauth_callback_url,  :facebook
  end

  test 'should alias oauth_authorize to mapped user auth_authorize' do
    assert_path_and_url :oauth_authorize_url, :github
    assert_path_and_url :oauth_authorize_url, :facebook
  end

  test 'should adds scope, provider and redirect_uri to authorize urls' do
    url = @controller.oauth_authorize_url(:user, :github) 
    assert_match "https://github.com/login/oauth/authorize?", url
    assert_match "scope=user%2Cpublic_repo", url
    assert_match "client_id=APP_ID", url
    assert_match "type=web_server", url
    assert_match "redirect_uri=http%3A%2F%2Ftest.host%2Fusers%2Foauth%2Fgithub%2Fcallback", url

    url = @controller.oauth_authorize_url(:user, :facebook) 
    assert_match "https://graph.facebook.com/oauth/authorize?", url
    assert_match "scope=email%2Coffline_access", url
    assert_match "client_id=APP_ID", url
    assert_match "type=web_server", url
    assert_match "redirect_uri=http%3A%2F%2Ftest.host%2Fusers%2Foauth%2Ffacebook%2Fcallback", url
  end
end
