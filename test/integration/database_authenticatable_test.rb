require 'test_helper'

class DatabaseAuthenticationTest < ActionController::IntegrationTest
  test 'sign in should not authenticate if not using proper authentication keys' do
    swap Devise, :authentication_keys => [:username] do
      sign_in_as_user
      assert_not warden.authenticated?(:user)
    end
  end

  test 'sign in with invalid email should return to sign in form with error message' do
    sign_in_as_admin do
      fill_in 'email', :with => 'wrongemail@test.com'
    end

    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:admin)
  end

  test 'sign in with invalid pasword should return to sign in form with error message' do
    sign_in_as_admin do
      fill_in 'password', :with => 'abcdef'
    end

    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:admin)
  end

  test 'error message is configurable by resource name' do
    store_translations :en, :devise => { :failure => { :admin => { :invalid => "Invalid credentials" } } } do
      sign_in_as_admin do
        fill_in 'password', :with => 'abcdef'
      end

      assert_contain 'Invalid credentials'
    end
  end
end