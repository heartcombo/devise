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
    end

    mail = TestMailerWithDefault.confirmation_instructions(create_user, "confirmation-token")
    assert mail.from, "from@example.com"
    assert mail.reply_to, "reply_to@example.com"
  end

  test "defaults to immediate delivery" do
    create_user

    assert_not_empty ActionMailer::Base.deliveries
    assert_empty ActiveJob::Base.queue_adapter.enqueued_jobs
  end

  test "supports deferred delivery with Devise.mailer_delivery_method = :deliver_later" do
    swap Devise, mailer_delivery_method: :deliver_later do
      create_user

      assert_empty ActionMailer::Base.deliveries
      assert_not_empty ActiveJob::Base.queue_adapter.enqueued_jobs
    end
  end
end
