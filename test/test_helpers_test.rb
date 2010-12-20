require 'test_helper'

class TestHelpersTest < ActionController::TestCase
  tests UsersController
  include Devise::TestHelpers

  test "redirects if attempting to access a page unauthenticated" do
    get :index
    assert_redirected_to new_user_session_path
    assert_equal "You need to sign in or sign up before continuing.", flash[:alert]
  end

  test "redirects if attempting to access a page with an unconfirmed account" do
    swap Devise, :confirm_within => 0 do
      user = create_user
      assert !user.active?

      sign_in user
      get :index
      assert_redirected_to new_user_session_path
    end
  end

  test "returns nil if accessing current_user with an unconfirmed account" do
    swap Devise, :confirm_within => 0 do
      user = create_user
      assert !user.active?

      sign_in user
      get :accept, :id => user
      assert_nil assigns(:current_user)
    end
  end

  test "does not redirect with valid user" do
    user = create_user
    user.confirm!

    sign_in user
    get :index
    assert_response :success
  end

  test "redirects if valid user signed out" do
    user = create_user
    user.confirm!

    sign_in user
    get :index

    sign_out user
    get :index
    assert_redirected_to new_user_session_path
  end

  test "defined Warden after_authentication callback should not be called when sign_in is called" do
    begin
      Warden::Manager.after_authentication do |user, auth, opts|
        flunk "callback was called while it should not"
      end

      user = create_user
      user.confirm!
      sign_in user
    ensure
      Warden::Manager._after_set_user.pop
    end
  end

  test "defined Warden before_logout callback should not be called when sign_out is called" do
    begin
      Warden::Manager.before_logout do |user, auth, opts|
        flunk "callback was called while it should not"
      end
      user = create_user
      user.confirm!

      sign_in user
      sign_out user
    ensure
      Warden::Manager._before_logout.pop
    end
  end
  
  test "before_failer call should work" do
    Warden::Manager.before_failure do |env,opts|
      # Do nothing
    end
    user = create_user
    user.confirm!

    sign_in user
  end

  test "allows to sign in with different users" do
    first_user = create_user
    first_user.confirm!

    sign_in first_user
    get :index
    assert_match /User ##{first_user.id}/, @response.body
    sign_out first_user

    second_user = create_user
    second_user.confirm!

    sign_in second_user
    get :index
    assert_match /User ##{second_user.id}/, @response.body
  end
end
