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

  def create_user
    User.create!(:email => "jose.valim@plataformatec.com", :password => "123456")
  end
end
