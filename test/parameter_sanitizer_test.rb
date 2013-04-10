require 'test_helper'
require 'devise/parameter_sanitizer'

class BaseSanitizerTest < ActiveSupport::TestCase
  def sanitizer
    @sanitizer ||= Devise::BaseSanitizer.new(:user, {})
  end

  test '#default_params returns the params passed in' do
    assert_equal({}, sanitizer.default_params)
  end
end

if defined?(ActionController::StrongParameters)

  require 'active_model/forbidden_attributes_protection'

  class ParameterSanitizerTest < ActiveSupport::TestCase
    def sanitizer(p={})
      @sanitizer ||= Devise::ParameterSanitizer.new(:user, p)
    end

    test '#permit allows adding an allowed param for a specific controller' do
      sanitizer.permit(:confirmations, :other)

      assert_equal [:email, :other], sanitizer.allowed_params[:confirmations]
    end

    test '#permit allows adding multiple allowed params for a specific controller' do
      sanitizer.permit(:confirmations, :other, :testing)

      assert_equal [:email, :other, :testing], sanitizer.allowed_params[:confirmations]
    end

    test '#permit! overrides allowed params for a specific controller' do
      sanitizer.permit!(:confirmations, :other, :testing)

      assert_equal [:other, :testing], sanitizer.allowed_params[:confirmations]
    end

    test '#forbid allows disallowing a param for a specific controller' do
      sanitizer.forbid(:confirmations, :email)

      assert_equal [], sanitizer.allowed_params[:confirmations]
    end

    test '#forbid allows disallowing multiple params for a specific controller' do
      sanitizer.forbid(:sessions, :email, :password)

      assert_equal [], sanitizer.allowed_params[:sessions]
    end

    test '#permit allows adding additional devise controllers' do
      sanitizer.permit(:invitations, :email)

      assert_equal [:email], sanitizer.allowed_params[:invitations]
    end

    test '#permit allows adding additional devise controllers with multiple params' do
      sanitizer.permit(:invitations, :email, :pin)

      assert_includes sanitizer.allowed_params[:invitations], :pin
      assert_includes sanitizer.allowed_params[:invitations], :email
    end

    test '#forbid fails gracefully when removing a missing param' do
      # perform twice, just to be sure it handles it gracefully
      sanitizer.forbid(:invitations, :email)
      sanitizer.forbid(:invitations, :email)

      assert_equal [], sanitizer.allowed_params[:invitations]
    end

    test '#forbid fails gracefully when removing multiple missing params' do
      # perform twice, just to be sure it handles it gracefully
      sanitizer.forbid(:invitations, :email, :badkey)
      sanitizer.forbid(:invitations, :email, :badkey)

      assert_equal [], sanitizer.allowed_params[:invitations]
    end

    test '#sanitize_for tries to require the resource name on params' do
      params = ActionController::Parameters.new({:admin => {}})

      assert_raises ActionController::ParameterMissing do
        sanitizer(params).sanitize_for(:sessions)
      end
    end

    test '#sanitize_for performs the permit step of strong_parameters, restricting passed attributes' do
      params = ActionController::Parameters.new({:user => {:admin => true}})

      # removes the admin flag
      assert_equal({}, sanitizer(params).sanitize_for(:sessions))
    end

    test '#sanitize_for respects any updates to allowed_params' do
      params = ActionController::Parameters.new({:user => {:admin => true}})
      sanitizer(params).permit(:sessions, :admin)

      assert_equal({'admin' => true}, sanitizer(params).sanitize_for(:sessions))
    end

    test '#sanitize_for works with newly added controllers' do
      params = ActionController::Parameters.new({:user => {:email => 'abc@example.com', :pin => '1234'}})
      sanitizer(params).permit(:invitations, :email, :pin)

      assert_equal({'email' => 'abc@example.com', 'pin' => '1234'}, sanitizer(params).sanitize_for(:invitations))
    end
  end
end

