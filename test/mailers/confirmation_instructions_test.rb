require 'test_helper'

class ConfirmationInstructionsTest < ActionMailer::TestCase

  def setup
    setup_mailer
    Devise.mailer_sender = 'test@example.com'
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

  test 'email sent after creating the user' do
    assert_not_nil mail
  end

  test 'content type should be set to html' do
    assert mail.content_type.include?('text/html')
  end

  test 'send confirmation instructions to the user email' do
    mail
    assert_equal [user.email], mail.to
  end

  test 'setup sender from configuration' do
    assert_equal ['test@example.com'], mail.from
  end

  test 'setup subject from I18n' do
    store_translations :en, :devise => { :mailer => { :confirmation_instructions => 'Account Confirmation' } } do
      assert_equal 'Account Confirmation', mail.subject
    end
  end

  test 'subject namespaced by model' do
    store_translations :en, :devise => { :mailer => { :user => { :confirmation_instructions => 'User Account Confirmation' } } } do
      assert_equal 'User Account Confirmation', mail.subject
    end
  end

  test 'body should have user info' do
    assert_match /#{user.email}/, mail.body.encoded
  end

  test 'body should have link to confirm the account' do
    host = ActionMailer::Base.default_url_options[:host]
    confirmation_url_regexp = %r{<a href=\"http://#{host}/users/confirmation\?confirmation_token=#{user.confirmation_token}">}
    assert_match confirmation_url_regexp, mail.body.encoded
  end

  test 'renders a scoped if scoped_views is set to true' do
    swap Devise, :scoped_views => true do
      assert_equal user.email, mail.body.decoded
    end
  end

  test 'renders a scoped if scoped_views is set in the mailer class' do
    begin
      Devise::Mailer.scoped_views = true
      assert_equal user.email, mail.body.decoded
    ensure
      Devise::Mailer.send :remove_instance_variable, :@scoped_views
    end
  end

  test 'mailer sender accepts a proc' do
    swap Devise, :mailer_sender => proc { "another@example.com" } do
      assert_equal ['another@example.com'], mail.from
    end
  end
end
