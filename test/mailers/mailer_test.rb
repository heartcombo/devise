# frozen_string_literal: true

require "test_helper"

class MailerTest < ActionMailer::TestCase
  test "pass given block to #mail call" do
    # Devise.send(:remove_const, :Mailer) if defined?(Devise::Mailer)
    # load "#{Devise::Engine.root}/app/mailers/devise/mailer.rb"
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

  # test 'correctly uses ActionMailer::Base as default parent_mailer' do
  #   Devise.send(:remove_const, :Mailer) if defined?(Devise::Mailer)
  #   load "#{Devise::Engine.root}/app/mailers/devise/mailer.rb"
  #   assert Devise::Mailer.superclass == ActionMailer::Base
  # end

  # test 'correctly inherits from Devise.parent_mailer' do
  #   class ::TestParentMailer; end
  #   swap Devise, parent_mailer: 'TestParentMailer' do
  #     Devise.send(:remove_const, :Mailer) if defined?(Devise::Mailer)
  #     load "#{Devise::Engine.root}/app/mailers/devise/mailer.rb"
  #     assert Devise::Mailer.superclass == TestParentMailer
  #   end
  # end

  # test 'do not define Devise::Mailer when Devise.parent_mailer class is not defined' do
  #   swap Devise, parent_mailer: 'NotDefinedParentMailer' do
  #     Devise.send(:remove_const, :Mailer) if defined?(Devise::Mailer)
  #     load "#{Devise::Engine.root}/app/mailers/devise/mailer.rb"
  #     refute defined?(Devise::Mailer)
  #   end
  # end

  # test 'defines Devise::Mailer when Devise.parent_mailer class is defined' do
  #   swap Devise, parent_mailer: 'DefinedParentMailer' do
  #     Devise.send(:remove_const, :Mailer) if defined?(Devise::Mailer)
  #     load "#{Devise::Engine.root}/app/mailers/devise/mailer.rb"
  #     assert defined?(Devise::Mailer)
  #   end
  # end
end
