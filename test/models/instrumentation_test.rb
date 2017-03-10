require 'test_helper'

class ConfirmableInstrumentationTest < ActiveSupport::TestCase
  test 'should send ActiveSupport::Notification when confirmation token is generated' do
    user = new_user
    with_subscription_to 'generate_confirmation_token.confirmable.devise' do
      user.send :generate_confirmation_token!
      assert_equal @sent_notifications.size, 1
    end
  end

  test 'should send ActiveSupport::Notification when confirmation instructions are sent' do
    user = new_user
    with_subscription_to 'send_confirmation_instructions.confirmable.devise' do
      user.save!
      assert_equal @sent_notifications.size, 1
    end
  end

  test 'should send ActiveSupport::Notification when confirmation instructions are resent' do
    user = new_user
    with_subscription_to 'resend_confirmation_instructions.confirmable.devise' do
      user.resend_confirmation_instructions
      assert_equal @sent_notifications.size, 1
    end
  end

  test 'should send ActiveSupport::Notification when re-confirmation instructions are sent' do
    user = new_user
    with_subscription_to 'send_reconfirmation_instructions.confirmable.devise' do
      user.send_reconfirmation_instructions
      assert_equal @sent_notifications.size, 1
    end
  end

  test 'should send ActiveSupport::Notification when the user confirms their account' do
    user = new_user
    with_subscription_to 'confirm.confirmable.devise' do
      user.confirm
      assert_equal @sent_notifications.size, 1
    end
  end

  test 'should send ActiveSupport::Notification when confirmation is skipped' do
    user = new_user
    with_subscription_to 'skip_confirmation!.confirmable.devise' do
      user.skip_confirmation!
      assert_equal @sent_notifications.size, 1
    end
  end
end

class MailerInstrumentationTest < ActiveSupport::TestCase
  test 'should send ActiveSupport::Notification when confirmation instructions are sent' do
    user = new_user
    with_subscription_to 'send.confirmation_instructions.notification.devise' do
      user.save!
      assert_equal @sent_notifications.size, 1
    end
  end

  test 'should send ActiveSupport::Notification when confirmation instructions are resent' do
    user = create_user
    with_subscription_to 'send.confirmation_instructions.notification.devise' do
      user.resend_confirmation_instructions
      assert_equal @sent_notifications.size, 1
    end
  end

  test 'should send ActiveSupport::Notification when re-confirmation instructions are sent' do
    user = create_user
    with_subscription_to 'send.confirmation_instructions.notification.devise' do
      user.send_reconfirmation_instructions
      assert_equal @sent_notifications.size, 1
    end
  end

  test 'should send ActiveSupport::Notification when password reset instructions are sent' do
    user = create_user
    with_subscription_to 'send.reset_password_instructions.notification.devise' do
      user.send_reset_password_instructions
      assert_equal @sent_notifications.size, 1
    end
  end
end

class RecoverableInstrumentationTest < ActiveSupport::TestCase
  test 'should send ActiveSupport::Notification when password reset instructions are sent' do
    user = create_user
    with_subscription_to 'send_reset_password_instructions.recoverable.devise' do
      user.send_reset_password_instructions
      assert_equal @sent_notifications.size, 1
    end
  end

  test 'should send ActiveSupport::Notification when password is reset' do
    user = create_user
    with_subscription_to 'reset_password.recoverable.devise' do
      user.reset_password 'a_new_password', 'a_new_password'
      assert_equal @sent_notifications.size, 1
    end
  end
end
