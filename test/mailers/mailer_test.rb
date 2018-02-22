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

  test "calls default procs with the proper arity" do
    class TestMailerWithDefault < Devise::Mailer
      default from: ->() { computed_from }

      def confirmation_instructions(record, token, opts = {})
        @token = token
        devise_mail(record, :confirmation_instructions, opts)
      end

      private

      def computed_from
        "from@example.com"
      end
    end

    mail = TestMailerWithDefault.confirmation_instructions(create_user, "confirmation-token")
    assert mail.from, "from@example.com"
  end
end
