require 'test_helper'
require 'devise/parameter_sanitizer'

class BaseSanitizerTest < ActiveSupport::TestCase
  def sanitizer
    Devise::BaseSanitizer.new(User, :user, { user: { "email" => "jose" } })
  end

  test 'returns chosen params' do
    assert_equal({ "email" => "jose" }, sanitizer.for(:sign_in))
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
      assert_equal({ "email" => "jose", "password" => "invalid", "remember_me" => "1" }, sanitizer.for(:sign_in))
    end

    test 'handles auth keys as a hash' do
      swap Devise, :authentication_keys => {:email => true} do
        sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid" })
        assert_equal({ "email" => "jose", "password" => "invalid" }, sanitizer.for(:sign_in))
      end
    end

    test 'filters some parameters on sign up by default' do
      sanitizer = sanitizer(user: { "email" => "jose", "role" => "invalid" })
      assert_equal({ "email" => "jose" }, sanitizer.for(:sign_up))
    end

    test 'filters some parameters on account update by default' do
      sanitizer = sanitizer(user: { "email" => "jose", "role" => "invalid" })
      assert_equal({ "email" => "jose" }, sanitizer.for(:account_update))
    end

    test 'allows custom hooks' do
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid" })
      sanitizer.for(:sign_in) { |user| user.permit(:email, :password) }
      assert_equal({ "email" => "jose", "password" => "invalid" }, sanitizer.for(:sign_in))
    end

    test 'adding permitted parameters for a single action' do
      sanitizer = sanitizer(user: { "email" => "jose", "username" => "jose1" })
      sanitizer.permitted_parameters.for(:sign_up).push(:username)

      assert_equal({ "email" => "jose", "username" => "jose1" }, sanitizer.for(:sign_up))
      assert_equal({ "email" => "jose" }, sanitizer.for(:sign_in))
    end

    test 'adding permitted parameters for all actions' do
      sanitizer = sanitizer(user: { "email" => "jose", "username" => "jose1" })
      sanitizer.permitted_parameters.add(:username)

      assert_equal({ "email" => "jose", "username" => "jose1" }, sanitizer.for(:sign_in))
      assert_equal({ "email" => "jose", "username" => "jose1" }, sanitizer.for(:sign_up))
      assert_equal({ "email" => "jose", "username" => "jose1" }, sanitizer.for(:account_update))
    end

    test 'removing default parameters' do
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid" })
      sanitizer.permitted_parameters.remove(:email)

      assert_equal({ "password" => "invalid" }, sanitizer.for(:sign_in))
      assert_equal({ "password" => "invalid" }, sanitizer.for(:sign_up))
      assert_equal({ "password" => "invalid" }, sanitizer.for(:account_update))
    end

    test 'adding multiple permitted parameters' do
      sanitizer = sanitizer(user: { "email" => "jose", "username" => "jose1", "role" => "valid" })

      sanitizer.permitted_parameters.add(:username, :role)
      assert_equal({ "email" => "jose", "username" => "jose1", "role" => "valid" }, sanitizer.for(:sign_in))
    end

    test 'removing multiple default parameters' do
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid", "remember_me" => "1" })
      sanitizer.permitted_parameters.remove(:email, :password)

      assert_equal({ "remember_me" => "1" }, sanitizer.for(:sign_in))
    end

    test 'raises on unknown hooks' do
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid" })
      assert_raise NotImplementedError do
        sanitizer.for(:unknown)
      end
    end
  end
end
