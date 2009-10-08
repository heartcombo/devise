require 'test_helper'

class DeviseHelperTest < ActionView::TestCase

  test 'should generate a link to sign in' do
    assert_equal %[<a href="#{new_session_path}">Sign in</a>], link_to_sign_in
  end

  test 'should generate a link to forgot password' do
    assert_equal %[<a href="#{new_password_path}">Forgot password?</a>], link_to_new_password
  end

  test 'should generate a link to confirmation instructions' do
    assert_equal %[<a href="#{new_confirmation_path}">Didn't receive confirmation instructions?</a>], link_to_new_confirmation
  end
end
