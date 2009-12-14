require 'test/test_helper'

class TestHelpersTest < ActionController::TestCase
  tests UsersController
  include Devise::TestHelpers

  test "redirects if attempting to access a page unauthenticated" do
    get :show
    assert_redirected_to "/users/sign_in?unauthenticated=true"
  end

  test "redirects if attempting to access a page with a unconfirmed account" do
    swap Devise, :confirm_within => 0 do
      sign_in create_user
      get :show
      assert_redirected_to "/users/sign_in?unconfirmed=true"
    end
  end

  test "does not redirect with valid user" do
    user = create_user
    user.confirm!

    sign_in user
    get :show
    assert_response :success
  end

  test "redirects if valid user signed out" do
    user = create_user
    user.confirm!

    sign_in user
    get :show

    sign_out user
    get :show
    assert_redirected_to "/users/sign_in?unauthenticated=true"
  end

  test "allows to sign in with different users" do
    first_user = create_user(1)
    first_user.confirm!

    sign_in first_user
    get :show
    assert_equal first_user.id.to_s, @response.body
    sign_out first_user

    second_user = create_user(2)
    second_user.confirm!

    sign_in second_user
    get :show
    assert_equal second_user.id.to_s, @response.body
  end

  def create_user(i=nil)
    User.create!(:email => "jose.valim#{i}@plataformatec.com", :password => "123456")
  end
end
