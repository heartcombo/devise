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
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid" })
      assert_equal({ "email" => "jose", "password" => "invalid" }, sanitizer.for(:sign_in))
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

    test 'raises on unknown hooks' do
      sanitizer = sanitizer(user: { "email" => "jose", "password" => "invalid" })
      assert_raise NotImplementedError do
        sanitizer.for(:unknown)
      end
    end
  end
end
