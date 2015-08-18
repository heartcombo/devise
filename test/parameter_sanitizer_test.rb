require 'test_helper'
require 'devise/parameter_sanitizer'

class BaseSanitizerTest < ActiveSupport::TestCase
  def sanitizer(params)
    Devise::BaseSanitizer.new(User, :user, params)
  end

  test 'returns chosen params' do
    sanitizer = sanitizer(user: { "email" => "jose" })
    assert_equal({ "email" => "jose" }, sanitizer.sanitize(:sign_in))
  end
end

if defined?(ActionController::StrongParameters)
  require 'active_model/forbidden_attributes_protection'

  class ParameterSanitizerTest < ActiveSupport::TestCase
    def sanitizer(params)
      params = ActionController::Parameters.new(params)
      Devise::ParameterSanitizer.new(User, :user, params)
    end

    test 'filters some parameters on sign in by default' do
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid", "remember_me" => "1" })
      sanitized = sanitizer.sanitize(:sign_in)
      sanitized = sanitized.to_h if sanitized.respond_to? :to_h
      assert_equal({ "email" => "jose", "password" => "invalid", "remember_me" => "1" }, sanitized)
    end

    test 'handles auth keys as a hash' do
      swap Devise, authentication_keys: {email: true} do
        sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid" })
        sanitized = sanitizer.sanitize(:sign_in)
        sanitized = sanitized.to_h if sanitized.respond_to? :to_h
        assert_equal({ "email" => "jose", "password" => "invalid" }, sanitized)
      end
    end

    test 'filters some parameters on sign up by default' do
      sanitizer = sanitizer(user: { "email" => "jose", "role" => "invalid" })
      sanitized = sanitizer.sanitize(:sign_up)
      sanitized = sanitized.to_h if sanitized.respond_to? :to_h
      assert_equal({ "email" => "jose" }, sanitized)
    end

    test 'filters some parameters on account update by default' do
      sanitizer = sanitizer(user: { "email" => "jose", "role" => "invalid" })
      sanitized = sanitizer.sanitize(:account_update)
      sanitized = sanitized.to_h if sanitized.respond_to? :to_h
      assert_equal({ "email" => "jose" }, sanitized)
    end

    test 'allows custom hooks' do
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid" })
      sanitizer.for(:sign_in) { |user| user.permit(:email, :password) }
      sanitized = sanitizer.sanitize(:sign_in)
      sanitized = sanitized.to_h if sanitized.respond_to? :to_h
      assert_equal({ "email" => "jose", "password" => "invalid" }, sanitized)
    end

    test 'adding multiple permitted parameters' do
      sanitizer = sanitizer(user: { "email" => "jose", "username" => "jose1", "role" => "valid" })
      sanitizer.for(:sign_in).concat([:username, :role])
      sanitized = sanitizer.sanitize(:sign_in)
      sanitized = sanitized.to_h if sanitized.respond_to? :to_h
      assert_equal({ "email" => "jose", "username" => "jose1", "role" => "valid" }, sanitized)
    end

    test 'removing multiple default parameters' do
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid", "remember_me" => "1" })
      sanitizer.for(:sign_in).delete(:email)
      sanitizer.for(:sign_in).delete(:password)
      sanitized = sanitizer.sanitize(:sign_in)
      sanitized = sanitized.to_h if sanitized.respond_to? :to_h
      assert_equal({ "remember_me" => "1" }, sanitized)
    end

    test 'raises on unknown hooks' do
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid" })
      assert_raise NotImplementedError do
        sanitizer.sanitize(:unknown)
      end
    end

    test 'passes parameters to filter as arguments to sanitizer' do
      params = {user: stub}
      sanitizer = Devise::ParameterSanitizer.new(User, :user, params)

      params[:user].expects(:permit).with(kind_of(Symbol), kind_of(Symbol), kind_of(Symbol))

      sanitizer.sanitize(:sign_in)
    end
  end
end
