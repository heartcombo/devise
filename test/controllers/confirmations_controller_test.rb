require 'test_helper'

class ConfirmationsControllerTest < Devise::ControllerTestCase
  tests Devise::ConfirmationsController
  include Devise::Test::ControllerHelpers

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create_user
  end

  test 'respond with unprocessable entity response if already confirmed' do
    get :show, params: { confirmation_token: @user.confirmation_token }
    assert_redirected_to 'http://test.host/users/sign_in'

    get :show, params: { format: :json, confirmation_token: @user.confirmation_token }
    assert_response :unprocessable_entity

    get :show, params: { confirmation_token: @user.confirmation_token }
    assert_response :unprocessable_entity
  end
end
