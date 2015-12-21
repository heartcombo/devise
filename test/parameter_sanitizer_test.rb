require 'test_helper'
require 'devise/parameter_sanitizer'

class ParameterSanitizerTest < ActiveSupport::TestCase
  def sanitizer(params)
    params = ActionController::Parameters.new(params)
    Devise::ParameterSanitizer.new(User, :user, params)
  end

  test 'permits the default parameters for sign in' do
    sanitizer = sanitizer('user' => { 'email' => 'jose' })
    sanitized = sanitizer.sanitize(:sign_in)

    assert_equal({ 'email' => 'jose' }, sanitized)
  end

  test 'permits the default parameters for sign up' do
    sanitizer = sanitizer('user' => { 'email' => 'jose', 'role' => 'invalid' })
    sanitized = sanitizer.sanitize(:sign_up)

    assert_equal({ 'email' => 'jose' }, sanitized)
  end

  test 'permits the default parameters for account update' do
    sanitizer = sanitizer('user' => { 'email' => 'jose', 'role' => 'invalid' })
    sanitized = sanitizer.sanitize(:account_update)

    assert_equal({ 'email' => 'jose' }, sanitized)
  end

  test 'permits news parameters for an existing action' do
    sanitizer = sanitizer('user' => { 'username' => 'jose' })
    sanitizer.permit(:sign_in, keys: [:username])
    sanitized = sanitizer.sanitize(:sign_in)

    assert_equal({ 'username' => 'jose' }, sanitized)
  end

  test 'permits news parameters for an existing action with a block' do
    sanitizer = sanitizer('user' => { 'username' => 'jose' })
    sanitizer.permit(:sign_in) do |user|
      user.permit(:username)
    end

    sanitized = sanitizer.sanitize(:sign_in)

    assert_equal({ 'username' => 'jose' }, sanitized)
  end

  test 'permit parameters for new actions' do
    sanitizer = sanitizer('user' => { 'email' => 'jose@omglol', 'name' => 'Jose' })
    sanitizer.permit(:invite_user, keys: [:email, :name])

    sanitized = sanitizer.sanitize(:invite_user)

    assert_equal({ 'email' => 'jose@omglol', 'name' => 'Jose' }, sanitized)
  end

  test 'fails when we do not have any permitted parameters for the action' do
    sanitizer = sanitizer('user' => { 'email' => 'jose', 'password' => 'invalid' })

    assert_raise NotImplementedError do
      sanitizer.sanitize(:unknown)
    end
  end

  test 'removes permitted parameters' do
    sanitizer = sanitizer('user' => { 'email' => 'jose@omglol', 'username' => 'jose' })

    sanitizer.permit(:sign_in, keys: [:username], except: [:email])
    sanitized = sanitizer.sanitize(:sign_in)

    assert_equal({ 'username' => 'jose' }, sanitized)
  end
end

class DeprecatedParameterSanitizerAPITest < ActiveSupport::TestCase
  class CustomSanitizer < Devise::ParameterSanitizer
    def sign_in
      default_params.permit(:username)
    end
  end

  def sanitizer(params)
    params = ActionController::Parameters.new(params)
    Devise::ParameterSanitizer.new(User, :user, params)
  end

  test 'overriding instance methods have precedence over the default sanitized attributes' do
    assert_deprecated do
      params =  ActionController::Parameters.new(user: { "username" => "jose", "name" => "Jose" })
      sanitizer = CustomSanitizer.new(User, :user, params)

      sanitized = sanitizer.sanitize(:sign_in)

      assert_equal({ "username" => "jose" }, sanitized)
    end
  end

  test 'adding new parameters by mutating the Array' do
    assert_deprecated do
      sanitizer = sanitizer('user' => { 'username' => 'jose' })
      sanitizer.for(:sign_in) << :username
      sanitized = sanitizer.sanitize(:sign_in)

      assert_equal({ 'username' => 'jose' }, sanitized)
    end
  end

   test 'adding new parameters with a block' do
     assert_deprecated do
       sanitizer = sanitizer('user' => { 'username' => 'jose' })
       sanitizer.for(:sign_in) { |user| user.permit(:username) }

       sanitized = sanitizer.sanitize(:sign_in)

       assert_equal({ 'username' => 'jose' }, sanitized)
     end
   end

  test 'removing multiple default parameters' do
    assert_deprecated do
      sanitizer = sanitizer('user' => { 'email' => 'jose', 'password' => 'invalid', 'remember_me' => '1' })
      sanitizer.for(:sign_in).delete(:email)
      sanitizer.for(:sign_in).delete(:password)
      sanitized = sanitizer.sanitize(:sign_in)

      assert_equal({ 'remember_me' => '1' }, sanitized)
    end
  end
end
