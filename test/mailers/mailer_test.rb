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

    Devise.mailer = TestMailer
    create_user
    mail = ActionMailer::Base.deliveries.first

    assert mail.content_transfer_encoding, "7bit"
  end
end
