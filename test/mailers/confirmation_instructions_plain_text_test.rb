require 'test/test_helper'

class ConfirmationInstructionsPlainTextTest < ActionMailer::TestCase

  def setup
    setup_mailer
    Devise.mailer_sender       = 'test@example.com'
    Devise.mailer_content_type = 'text/plain'
  end
  
  def teardown
    Devise.mailer_content_type = 'text/html' # the default
  end

  def user
    @user ||= create_user
  end

  def mail
    @mail ||= begin
      user
      ActionMailer::Base.deliveries.first
    end
  end

  test 'content type should be set to plain when manually configured' do
    assert_equal 'text/plain', mail.content_type
  end

end
