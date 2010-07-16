require 'test_helper'

class OAuthableTest < ActionController::IntegrationTest
  FACEBOOK_INFO = {
    :username => 'usertest',
    :email => 'user@test.com'
  }

  ACCESS_TOKEN = {
    :access_token => "plataformatec"
  }

  setup do
    Devise::Oauth.short_circuit_authorizers!
  end

  teardown do
    Devise::Oauth.unshort_circuit_authorizers!
    Devise::Oauth.reset_stubs!
    User.singleton_class.remove_possible_method(:find_for_github_oauth)
  end

  def stub_github!(times=1)
    def User.find_for_github_oauth(*); end

    Devise::Oauth.stub!(:github) do |b|
      b.post('/login/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
    end
  end

  def stub_facebook!(times=1)
    # If times != 1, use invalid data
    data = (times != 1) ? FACEBOOK_INFO.except(:email) : FACEBOOK_INFO

    Devise::Oauth.stub!(:facebook) do |b|
      b.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
      times.times {
        b.get('/me?access_token=plataformatec') { [200, {}, data.to_json] }
      }
    end
  end

  test "[BASIC] setup with persisted user" do
    stub_facebook!

    assert_difference "User.count", 1 do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert_current_url "/"
    assert_contain "Successfully authorized from Facebook account."

    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)
    assert "plataformatec", warden.user(:user).facebook_token
  end

  test "[BASIC] setup with not persisted user and follow up" do
    stub_facebook!(2)

    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert_contain "1 error prohibited this user from being saved"
    assert_contain "Email can't be blank"

    assert_not warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)

    fill_in "Email", :with => "user.form@test.com"
    click_button "Sign up"

    assert_current_url "/"
    assert_contain "You have signed up successfully."
    assert_contain "Hello User user.form@test.com"

    assert warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)
    assert "plataformatec", warden.user(:user).facebook_token
  end

  test "[BASIC] setup updating an existing user in database" do
    stub_facebook!
    user = create_user

    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert_current_url "/"
    assert_contain "Successfully authorized from Facebook account."

    assert_equal user, warden.user(:user)
    assert_equal "plataformatec", user.reload.facebook_token
  end

  test "[BASIC] setup updating an existing user in session" do
    stub_facebook!

    # Create an user and change his e-mail
    user = sign_in_as_user
    user.update_attribute(:email, "another@test.com")

    assert_no_difference "User.count" do
      visit "/"
      click_link "Sign in with Facebook"
    end

    assert_current_url "/"
    assert_contain "Successfully authorized from Facebook account."

    assert_equal user, warden.user(:user)
    assert_equal "another@test.com", warden.user(:user).email
    assert_equal "plataformatec", user.reload.facebook_token
  end

  test "[BASIC] setup skipping oauth callback" do
    stub_github!

    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Github"
    end

    assert_current_url "/users/sign_in"
    assert_contain "Skipped Oauth authorization for Github."

    assert_not warden.authenticated?(:user)
    assert_not warden.authenticated?(:admin)
  end

  test "[SESSION CLEANUP] ensures session is cleaned up after sign up" do
    stub_facebook!(2)

    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert_contain "1 error prohibited this user from being saved"
    fill_in "Email", :with => "user.form@test.com"
    click_button "Sign up"

    assert_contain "You have signed up successfully."
    visit "/users/sign_out"

    user = sign_in_as_user
    assert_nil warden.user(:user).facebook_token
    assert_equal user, warden.user(:user)
  end

  test "[SESSION CLEANUP] ensures session is cleaned up on cancel" do
    stub_facebook!(2)

    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert_contain "1 error prohibited this user from being saved"
    visit "/users/cancel"

    user = sign_in_as_user
    assert_nil warden.user(:user).facebook_token
    assert_equal user, warden.user(:user)
  end

  test "[SESSION CLEANUP] ensures session is cleaned up on sign in" do
    stub_facebook!(2)

    assert_no_difference "User.count" do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
    end

    assert_contain "1 error prohibited this user from being saved"

    user = sign_in_as_user
    assert_nil warden.user(:user).facebook_token
    assert_equal user, warden.user(:user)
  end

  test "[I18N] scopes messages based on oauth callback for success" do
    stub_facebook!

    store_translations :en, :devise => { :oauth_callbacks => {
      :facebook => { :success => "Welcome facebooker" } } } do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
      assert_contain "Welcome facebooker"
    end
  end

  test "[I18N] scopes messages based on oauth callback and resource name for success" do
    stub_facebook!

    store_translations :en, :devise => { :oauth_callbacks => {
      :user => { :facebook => { :success => "Welcome facebooker user" } },
      :facebook => { :success => "Welcome facebooker" } } } do
      visit "/users/sign_in"
      click_link "Sign in with Facebook"
      assert_contain "Welcome facebooker user"
    end
  end

  test "[I18N] scopes messages based on oauth callback for skipped" do
    stub_github!

    store_translations :en, :devise => { :oauth_callbacks => {
      :github => { :skipped => "Skipped github" } } } do
      visit "/users/sign_in"
      click_link "Sign in with Github"
      assert_contain "Skipped github"
    end
  end

  test "[I18N] scopes messages based on oauth callback and resource name for skipped" do
    stub_github!

    store_translations :en, :devise => { :oauth_callbacks => {
      :user => { :github => { :skipped => "Skipped github user" } },
      :github => { :skipped => "Skipped github" } } } do
      visit "/users/sign_in"
      click_link "Sign in with Github"
      assert_contain "Skipped github user"
    end
  end

  test "[FAILURE] shows 404 if no code or error are given as params" do
    assert_raise AbstractController::ActionNotFound do
      visit "/users/oauth/facebook/callback"
    end
  end

  test "[FAILURE] raises an error if model does not implement a hook" do
    begin
      visit "/users/oauth/github/callback?code=123456"
      raise "Expected visit to raise an error"
    rescue Exception => e
      assert_match "User does not respond to find_for_github_oauth", e.message 
    end
  end

  test "[FAILURE] handles callback error parameter according to the specification" do
    visit "/users/oauth/facebook/callback?error=access_denied"
    assert_current_url "/users/sign_in"
    assert_contain 'Could not authorize you from Facebook because "Access denied".'
  end

  test "[FAILURE] handles callback error_reason just for Facebook compatibility" do
    visit "/users/oauth/facebook/callback?error_reason=access_denied"
    assert_current_url "/users/sign_in"
    assert_contain 'Could not authorize you from Facebook because "Access denied".'
  end

  test "[FAILURE][I18N] uses I18n for custom messages" do
    store_translations :en, :devise => { :oauth_callbacks => { :access_denied => "Access denied bro" } } do
      visit "/users/oauth/facebook/callback?error=access_denied"
      assert_current_url "/users/sign_in"
      assert_contain "Access denied bro"
    end
  end

  test "[FAILURE][I18N] uses I18n with oauth callback scope for custom messages" do
    store_translations :en, :devise => { :oauth_callbacks => {
      :facebook => { :access_denied => "Access denied bro" } } } do
      visit "/users/oauth/facebook/callback?error=access_denied"
      assert_current_url "/users/sign_in"
      assert_contain "Access denied bro"
    end
  end

  test "[FAILURE][I18N] uses I18n with oauth callback scope and resource name for custom messages" do
    store_translations :en, :devise => { :oauth_callbacks => {
      :user => { :facebook => { :access_denied => "Access denied user" } },
      :facebook => { :access_denied => "Access denied bro" } } } do
      visit "/users/oauth/facebook/callback?error=access_denied"
      assert_current_url "/users/sign_in"
      assert_contain "Access denied user"
    end
  end

  test "[FAILURE][I18N] trim messages to avoid long symbols lookups" do
    store_translations :en, :devise => { :oauth_callbacks => {
      :facebook => { ("a"*25) => "Access denied bro" } } } do
      visit "/users/oauth/facebook/callback?error=#{"a"*100}"
      assert_current_url "/users/sign_in"
      assert_contain "Access denied bro"
    end
  end
end