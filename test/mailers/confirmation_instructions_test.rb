require 'test_helper'

class ConfirmationInstructionsTest < ActionMailer::TestCase

  def setup
    setup_mailer
    I18n.backend.store_translations :en, {:devise => { :notifier => { :confirmation_instructions => 'Account Confirmation' } }}
    Notifier.sender = 'test@example.com'
    @user = create_user
    @mail = ActionMailer::Base.deliveries.first
  end

  test 'email sent after creating the user' do
    assert_not_nil @mail
  end

  test 'content type should be set to html' do
    assert_equal 'text/html', @mail.content_type
  end

  test 'send confirmation instructions to the user email' do
    assert_equal [@user.email], @mail.to
  end

  test 'setup sender from configuration' do
    assert_equal ['test@example.com'], @mail.from
  end

  test 'setup subject from I18n' do
    assert_equal 'Account Confirmation', @mail.subject
  end

  test 'body should have user info' do
    assert_match /#{@user.email}/, @mail.body
  end

  test 'body should have link to confirm the account' do
    host = ActionMailer::Base.default_url_options[:host]
    confirmation_url_regexp = %r{<a href=\"http://#{host}/users/confirmation\?confirmation_token=#{@user.confirmation_token}">}
    assert_match confirmation_url_regexp, @mail.body
  end
end
