require 'test_helper'

class PasswordsControllerTest < Devise::ControllerTestCase
  tests Devise::PasswordsController
  include Devise::Test::ControllerHelpers

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create_user.tap(&:confirm)
    @raw  = @user.send_reset_password_instructions
  end

  def get_edit(params = {})
    get :edit, params: params
  end

  def get_edit_with_params(reset_token)
    get :edit, params: { "reset_password_token" => reset_token }
  end

  def put_update_with_params
    put :update, params: { "user" => {
        "reset_password_token" => @raw, "password" => "1234567", "password_confirmation" => "1234567"
      }
    }
  end

  test 'redirect to after_sign_in_path_for if after_resetting_password_path_for is not overridden' do
    session[:reset_password_token] = @raw
    put_update_with_params
    assert_redirected_to "http://test.host/"
  end

  test 'redirect accordingly if after_resetting_password_path_for is overridden' do
    session[:reset_password_token] = @raw
    custom_path = "http://custom.path/"
    Devise::PasswordsController.any_instance.stubs(:after_resetting_password_path_for).with(@user).returns(custom_path)

    put_update_with_params
    assert_redirected_to custom_path
  end

  test 'redirect to new session path if reset token missing from params and session ' do
    custom_path = "http://custom.path/"
    Devise::PasswordsController.any_instance.stubs(:new_session_path).returns(custom_path)

    get_edit
    assert_redirected_to custom_path
  end

  test 'reset token removed from query params and stored in session' do
    custom_path = "http://custom.path/"
    Devise::PasswordsController.any_instance.stubs(:edit_password_path).returns(custom_path)

    reset_token = "TEST_RESET_TOKEN"
    get_edit_with_params(reset_token)

    assert_redirected_to custom_path
  end
end
