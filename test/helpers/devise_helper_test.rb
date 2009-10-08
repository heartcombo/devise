require 'test_helper'

class DeviseHelperTest < ActionView::TestCase

  def store_translations(translations={})
    I18n.locale = :'pt-BR'
    I18n.backend.store_translations(:'pt-BR', :devise => { :links => translations })
  end

  def teardown
    I18n.locale = :en
    I18n.reload!
  end

  test 'should generate a link to sign in' do
    assert_equal %[<a href="#{new_session_path}">Sign in</a>], link_to_sign_in
  end

  test 'should use i18n to translante sign in link' do
    store_translations(:sign_in => 'Login')
    assert_equal %[<a href="#{new_session_path}">Login</a>], link_to_sign_in
  end

  test 'should generate a link to forgot password' do
    assert_equal %[<a href="#{new_password_path}">Forgot password?</a>], link_to_new_password
  end

  test 'should use i18n to translante forgot password link' do
    store_translations(:new_password => 'New password?')
    assert_equal %[<a href="#{new_password_path}">New password?</a>], link_to_new_password
  end

  test 'should generate a link to confirmation instructions' do
    assert_equal %[<a href="#{new_confirmation_path}">Didn't receive confirmation instructions?</a>], link_to_new_confirmation
  end

  test 'should use i18n to translante confirmation link' do
    store_translations(:new_confirmation => 'New confirmation?')
    assert_equal %[<a href="#{new_confirmation_path}">New confirmation?</a>], link_to_new_confirmation
  end
end
