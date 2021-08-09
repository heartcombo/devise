# frozen_string_literal: true

require 'test_helper'

class PasswordsControllerTest < Devise::ControllerTestCase
  tests Devise::PasswordsController
  include Devise::Test::ControllerHelpers

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create_user.tap(&:confirm)
    @raw  = @user.send_reset_password_instructions
  end

  def put_update_with_params
    put :update, params: { "user" => {
        "reset_password_token" => @raw, "password" => "1234567", "password_confirmation" => "1234567"
      }
    }
  end

  test '#edit redirect if reset_password_token is missing' do
    get :edit
    assert_equal "You can't access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided.", flash[:alert]
    assert_redirected_to "http://test.host/users/sign_in"
  end

  test '#edit redirect if reset_password_token is invalid' do
    get :edit, params: { reset_password_token: 'abcdef' }
    assert_equal "This password recovery link is invalid, please request a new one.", flash[:alert]
    assert_redirected_to "http://test.host/users/password/new"
  end

  test '#edit redirect if reset_password_token has expired' do
    @user.reset_password_sent_at = @user.class.reset_password_within - 1.second
    @user.save
    get :edit, params: { reset_password_token: @raw }
    assert_equal "This password recovery link has expired, please request a new one.", flash[:alert]
    assert_redirected_to "http://test.host/users/password/new"
  end

  test 'redirect to after_sign_in_path_for if after_resetting_password_path_for is not overridden' do
    put_update_with_params
    assert_redirected_to "http://test.host/"
  end

  test 'redirect accordingly if after_resetting_password_path_for is overridden' do
    custom_path = "http://custom.path/"
    Devise::PasswordsController.any_instance.stubs(:after_resetting_password_path_for).with(@user).returns(custom_path)

    put_update_with_params
    assert_redirected_to custom_path
  end

  test 'calls after_database_authentication callback after sign_in immediately after password update' do
    User.any_instance.expects :after_database_authentication
    put_update_with_params
  end
end
