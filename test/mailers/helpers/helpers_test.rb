# frozen_string_literal: true

require 'test_helper'

class HelpersTest < ActiveSupport::TestCase
  def setup
    Devise.strict_single_recipient_emails = []
  end

  def user
    @user ||= create_user
  end

  def send_mail(opts={})
    Devise.mailer.reset_password_instructions(
      user,
      'fake-token',
      opts,
    ).deliver
  end

  test "an email passed in opts is used instead of the record's email" do
    mail = send_mail({to: "test2@example.com"})

    assert_equal ["test2@example.com"], mail.to
  end

  test "multiple recipients are permitted when setting configured to empty array" do
    mail = send_mail({
      to: ["test1@example.com", "test2@example.com"],
      bcc: ["admin@example.com"]
    })

    assert_equal ["test1@example.com", "test2@example.com"], mail.to
    assert_equal ["admin@example.com"], mail.bcc
  end

  test "multiple recipients are permitted setting configured to another action" do
    Devise.strict_single_recipient_emails = [:unlock_instructions]
    mail = send_mail({
      to: ["test1@example.com", "test2@example.com"],
      bcc: ["admin@example.com"]
    })

    assert_equal ["test1@example.com", "test2@example.com"], mail.to
    assert_equal ["admin@example.com"], mail.bcc
  end

  test "single to recipient does not raises an error when action has strict enforcement" do
    Devise.strict_single_recipient_emails = [:reset_password_instructions]
    mail = send_mail

    assert_equal [user.email], mail.to
  end

  test "multiple to recipients raises an error when action has strict enforcement" do

    Devise.strict_single_recipient_emails = [:reset_password_instructions]

    [
      { to: 'test1@example.com', 'to' => 'test2@example.com' },
      { to: 'test1@example.com,test2@example.com' },
      { to: 'test1@example.com;test2@example.com' },
      { to: ['test1@example.com', 'test2@example.com'] }
    ].each do |headers|
      assert_raises(Devise::Mailers::Helpers::MultipleRecipientsError) do
        send_mail(headers)
      end
    end
  end

  test "bcc raises an error when action has strict enforcement" do
    Devise.strict_single_recipient_emails = [:reset_password_instructions]
    assert_raises(Devise::Mailers::Helpers::MultipleRecipientsError) do
      send_mail({bcc: ["admin@example.com"]})
    end
  end

  test "cc raises an error when action has strict enforcement" do
    Devise.strict_single_recipient_emails = [:reset_password_instructions]
    assert_raises(Devise::Mailers::Helpers::MultipleRecipientsError) do
      send_mail({cc: ["admin@example.com"]})
    end
  end

end