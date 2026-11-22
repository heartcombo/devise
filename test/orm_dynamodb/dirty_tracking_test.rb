# frozen_string_literal: true

require "test_helper"

if DEVISE_ORM == :dynamodb
  class DynamodbDirtyTrackingTest < ActiveSupport::TestCase
    test "the model includes the DynamoDB dirty tracking methods" do
      assert_includes User.ancestors, Devise::Orm::DirtyTrackingDynamodbMethods
      assert Devise::Orm.dynamodb?(User)
    end

    test "devise_will_save_change_to_email? is true before save and false after" do
      user = create_user(email: "before@example.com")
      user.email = "after@example.com"

      assert user.devise_will_save_change_to_email?

      user.save!

      refute user.devise_will_save_change_to_email?
    end

    test "after update, devise_saved_change_to_email? is true and the previous email is kept" do
      user = create_user(email: "old@example.com")

      assert user.update(email: "new@example.com")

      assert user.devise_saved_change_to_email?
      assert_equal "old@example.com", user.devise_email_before_last_save
      assert_equal "new@example.com", user.email
    end

    test "after a save without an email change, devise_saved_change_to_email? is false" do
      user = create_user(email: "stable@example.com")

      assert user.update(username: "renamed")

      refute user.devise_saved_change_to_email?
    end

    test "devise_saved_change_to_encrypted_password? is true after a password change" do
      user = create_user
      assert user.update(password: "newpassword1", password_confirmation: "newpassword1")

      assert user.devise_saved_change_to_encrypted_password?
    end

    test "devise_email_in_database returns the stored email before a pending change" do
      user = create_user(email: "stored@example.com")
      user.email = "pending@example.com"

      assert_equal "stored@example.com", user.devise_email_in_database
    end

    test "email change notification is sent to the old address from inside the update callback" do
      swap Devise, send_email_changed_notification: true do
        user = create_user(email: "callback-old@example.com")

        assert_email_sent "callback-old@example.com" do
          assert user.update(email: "callback-new@example.com")
        end
      end
    end

    test "password change notification is sent from inside the update callback" do
      swap Devise, send_password_change_notification: true do
        user = create_user(email: "pw-notify@example.com")

        assert_email_sent "pw-notify@example.com" do
          assert user.update(password: "newpassword1", password_confirmation: "newpassword1")
        end
      end
    end

    test "no email change notification when the email did not change" do
      swap Devise, send_email_changed_notification: true do
        user = create_user(email: "no-change@example.com")

        assert_email_not_sent do
          assert user.update(username: "still-same-email")
        end
      end
    end

    test "devise_unconfirmed_email_will_change! makes the record dirty so save writes unconfirmed_email" do
      user = create_user(unconfirmed_email: nil)

      user.devise_unconfirmed_email_will_change!
      assert user.devise_respond_to_and_will_save_change_to_attribute?(:unconfirmed_email)

      user.save!
      assert_nil User.find(user.id).unconfirmed_email
    end

    test "devise_respond_to_and_will_save_change_to_attribute? reports pending changes" do
      user = create_user
      refute user.devise_respond_to_and_will_save_change_to_attribute?(:username)

      user.username = "changed_name"
      assert user.devise_respond_to_and_will_save_change_to_attribute?(:username)
    end
  end
end
