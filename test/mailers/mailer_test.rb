require "test_helper"

class MailerTest < ActionMailer::TestCase
  test "pass given block to #mail call" do
    class TestMailer < Devise::Mailer
      def confirmation_instructions(record, token, opts = {})
        @token = token
        devise_mail(record, :confirmation_instructions, opts) do |format|
          format.html(content_transfer_encoding: "7bit")
        end
      end
    end

    mail = TestMailer.confirmation_instructions(create_user, "confirmation-token")

    assert mail.content_transfer_encoding, "7bit"
  end

  test "devise mailer should use deliver_later if deliver_later_option is true" do
    swap Devise, deliver_later_option: true do
      user = create_user
      deliver_method = user.send(:delivery_method).to_s
      assert_equal deliver_method, "deliver_later"
    end
  end
end
