require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  tests Devise::PasswordsController
  include Devise::TestHelpers

  def setup
    request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create_user
    @user.send_reset_password_instructions
  end

  def put_update_with_params
    put :update, "user"=>{"reset_password_token"=>@user.reset_password_token, "password"=>"123456", "password_confirmation"=>"123456"}
  end

  test 'redirect to after_sign_in_path_for if after_resetting_password_path_for is not overridden' do
    put_update_with_params
    assert_redirected_to "http://test.host/"
  end

  test 'redirect accordingly if after_resetting_password_path_for is overridden' do
    custom_path = "http://custom.path/"
    # Overwrite after_resetting_password_path_for with custom_path
    Devise::PasswordsController.any_instance.stubs(:after_resetting_password_path_for).with(@user).returns(custom_path)
    put_update_with_params
    assert_redirected_to custom_path
  end
end
