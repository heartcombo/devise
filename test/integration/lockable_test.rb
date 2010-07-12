require 'test_helper'

class LockTest < ActionController::IntegrationTest
  
  def visit_user_unlock_with_token(unlock_token)
    visit user_unlock_path(:unlock_token => unlock_token)
  end

  test 'user should be able to request a new unlock token' do
    user = create_user(:locked => true)
    ActionMailer::Base.deliveries.clear

    visit new_user_session_path
    click_link "Didn't receive unlock instructions?"

    fill_in 'email', :with => user.email
    click_button 'Resend unlock instructions'

    assert_template 'sessions/new'
    assert_contain 'You will receive an email with instructions about how to unlock your account in a few minutes'
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'unlocked user should not be able to request a unlock token' do
    user = create_user(:locked => false)
    ActionMailer::Base.deliveries.clear

    visit new_user_session_path
    click_link "Didn't receive unlock instructions?"

    fill_in 'email', :with => user.email
    click_button 'Resend unlock instructions'

    assert_template 'unlocks/new'
    assert_contain 'not locked'
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test 'unlocked pages should not be available if email strategy is disabled' do
    visit "/admins/sign_in"

    assert_raise Webrat::NotFoundError do
      click_link "Didn't receive unlock instructions?"
    end

    assert_raise NameError do
      visit new_admin_unlock_path
    end

    visit "/admins/unlock/new"
    assert_response :not_found
  end

  test 'user with invalid unlock token should not be able to unlock an account' do
    visit_user_unlock_with_token('invalid_token')

    assert_response :success
    assert_current_url '/users/unlock?unlock_token=invalid_token'
    assert_have_selector '#error_explanation'
    assert_contain /Unlock token(.*)invalid/
  end

  test "locked user should be able to unlock account" do
    user = create_user(:locked => true)
    assert user.access_locked?

    visit_user_unlock_with_token(user.unlock_token)

    assert_current_url '/'
    assert_contain 'Your account was successfully unlocked.'

    assert_not user.reload.access_locked?
  end

  test "sign in user automatically after unlocking it's account" do
    user = create_user(:locked => true)
    visit_user_unlock_with_token(user.unlock_token)
    assert warden.authenticated?(:user)
  end

  test "user should not be able to sign in when locked" do
    user = sign_in_as_user(:locked => true)
    assert_template 'sessions/new'
    assert_contain 'Your account is locked.'
    assert_not warden.authenticated?(:user)
  end

  test "user should not send a new e-mail if already locked" do
    user = create_user(:locked => true)
    user.failed_attempts = User.maximum_attempts + 1
    user.save!

    ActionMailer::Base.deliveries.clear

    sign_in_as_user(:password => "invalid")
    assert_contain 'Your account is locked.'
    assert ActionMailer::Base.deliveries.empty?
  end

  test 'error message is configurable by resource name' do
    store_translations :en, :devise => {
      :failure => { :user => { :locked => "You are locked!" } }
    } do
      user = sign_in_as_user(:locked => true)
      assert_contain 'You are locked!'
    end
  end

end
