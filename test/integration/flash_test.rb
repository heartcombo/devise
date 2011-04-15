require 'test_helper'

class FlashTest < ActionController::IntegrationTest
  test 'require_no_authentication should set the already_authenticated flash message' do
    sign_in_as_user
    visit new_user_session_path
    assert_equal flash[:alert], I18n.t("devise.failure.already_authenticated")
  end
end
