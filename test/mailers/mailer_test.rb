# frozen_string_literal: true

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

  test "default values defined as proc with different arity are handled correctly" do
    class TestMailerWithDefault < Devise::Mailer
      default from: -> { computed_from }
      default reply_to: ->(_) { computed_reply_to }
      default to: -> { computed_to }

      def confirmation_instructions(record, token, opts = {})
        @token = token
        devise_mail(record, :confirmation_instructions, opts)
      end

      private

      def computed_from
        "from@example.com"
      end

      def computed_reply_to
        "reply_to@example.com"
      end

      def computed_to
        "to@example.com"
      end
    end

    mail = TestMailerWithDefault.confirmation_instructions(create_user, "confirmation-token")
    
    email_headers = mail.header
    assert_equal "from@example.com", email_headers[:from].to_s
    assert_equal "reply_to@example.com", email_headers[:reply_to].to_s
    assert_equal "to@example.com", email_headers[:to].to_s
  end
end
