# frozen_string_literal: true

require 'test_helper'

class MagicLinkInstructionsTest < ActionMailer::TestCase
  def setup
    setup_mailer
    Devise.mailer = 'Devise::Mailer'
    Devise.mailer_sender = 'test@example.com'
  end

  def teardown
    Devise.mailer = 'Devise::Mailer'
    Devise.mailer_sender = 'please-change-me@config-initializers-devise.com'
  end

  def user
    @user ||= begin
      user = create_user
      user.send_magic_link_instructions
      user
    end
  end

  def mail
    @mail ||= begin
      user
      ActionMailer::Base.deliveries.last
    end
  end

  test 'email sent after requesting a magic link' do
    assert_not_nil mail
  end

  test 'content type should be set to html' do
    assert_includes mail.content_type, 'text/html'
  end

  test 'send magic link instructions to the user email' do
    assert_equal [user.email], mail.to
  end

  test 'set up sender from configuration' do
    assert_equal ['test@example.com'], mail.from
  end

  test 'set up reply to as copy from sender' do
    assert_equal ['test@example.com'], mail.reply_to
  end

  test 'set up subject from I18n' do
    store_translations :en, devise: { mailer: { magic_link_instructions: { subject: 'Your login link' } } } do
      assert_equal 'Your login link', mail.subject
    end
  end

  test 'subject namespaced by model' do
    store_translations :en, devise: { mailer: { magic_link_instructions: { user_subject: 'User login link' } } } do
      assert_equal 'User login link', mail.subject
    end
  end

  test 'body should have user info' do
    assert_match user.email, mail.body.encoded
  end

  test 'body should have link to sign in with the magic link token' do
    host, port = ActionMailer::Base.default_url_options.values_at :host, :port

    if mail.body.encoded =~ %r{<a href=\"http://#{host}:#{port}/users/magic_link\?magic_link_token=([^"]+)">}
      assert_equal user.magic_link_token, Devise.token_generator.digest(user.class, :magic_link_token, $1)
    else
      flunk "expected magic link url regex to match"
    end
  end

  test 'mailer sender accepts a proc' do
    swap Devise, mailer_sender: proc { "another@example.com" } do
      assert_equal ['another@example.com'], mail.from
    end
  end
end
