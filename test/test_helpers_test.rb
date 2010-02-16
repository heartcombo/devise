require 'test/test_helper'

class TestHelpersTest < ActionController::TestCase
  tests UsersController
  include Devise::TestHelpers

  test "redirects if attempting to access a page unauthenticated" do
    get :index
    assert_redirected_to "/users/sign_in?unauthenticated=true"
  end

  test "redirects if attempting to access a page with a unconfirmed account" do
    swap Devise, :confirm_within => 0 do
      sign_in create_user
      get :index
      assert_redirected_to "/users/sign_in?unconfirmed=true"
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
    assert_redirected_to "/users/sign_in?unauthenticated=true"
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
