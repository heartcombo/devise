require 'test_helper'

class ParameterSanitizerTest < ActiveSupport::TestCase
  def sanitizer
    Devise::ParameterSanitizer.new
  end

  test '#permitted_params_for allows querying of allowed parameters by controller' do
    assert_equal [:email], sanitizer.permitted_params_for(:confirmations_controller)
    assert_equal [:email, :password, :password_confirmation, :reset_password_token], sanitizer.permitted_params_for(:password)
    assert_equal [:email], sanitizer.permitted_params_for(:unlocks)
  end

  test '#permitted_params_for returns an empty array for a bad key' do
    assert_equal [], sanitizer.permitted_params_for(:bad_key)
  end

  test '#permit_devise_param allows adding an allowed param for a specific controller' do
    subject = sanitizer

    subject.permit_devise_param(:confirmations_controller, :other)

    assert_equal [:email, :other], subject.permitted_params_for(:confirmations_controller)
  end

  test '#remove_permitted_devise_param allows disallowing a param for a specific controller' do
    subject = sanitizer

    subject.remove_permitted_devise_param(:confirmations_controller, :email)

    assert_equal [], subject.permitted_params_for(:confirmations_controller)
  end

  test '#permit_devise_param allows adding additional devise controllers' do
    subject = sanitizer

    subject.permit_devise_param(:invitations_controller, :email)

    assert_equal [:email], subject.permitted_params_for(:invitations)
  end

  test '#remove_permitted_devise_param fails gracefully when removing a missing param' do
    subject = sanitizer

    # perform twice, just to be sure it handles it gracefully
    subject.remove_permitted_devise_param(:invitations_controller, :email)
    subject.remove_permitted_devise_param(:invitations_controller, :email)

    assert_equal [], subject.permitted_params_for(:invitations)
  end
end

