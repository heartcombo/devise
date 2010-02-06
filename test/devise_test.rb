require 'test/test_helper'

module Devise
  def self.clean_warden_config!
    @warden_config = nil
  end
end

class DeviseTest < ActiveSupport::TestCase
  test 'model options can be configured through Devise' do
    swap Devise, :confirm_within => 113, :pepper => "foo" do
      assert_equal 113, Devise.confirm_within
      assert_equal "foo", Devise.pepper
    end
  end

  test 'setup block yields self' do
    Devise.setup do |config|
      assert_equal Devise, config
    end
  end

  test 'warden manager configuration' do
    config = Warden::Config.new
    Devise.configure_warden(config)

    assert_equal Devise::FailureApp, config.failure_app
    assert_equal [:rememberable, :http_authenticatable, :token_authenticatable, :authenticatable], config.default_strategies
    assert_equal :user, config.default_scope
    assert config.silence_missing_strategies?
  end

  test 'warden manager user configuration through a block' do
    begin
      @executed = false
      Devise.warden do |config|
        @executed = true
        assert_kind_of Warden::Config, config
      end

      Devise.configure_warden(Warden::Config.new)
      assert @executed
    ensure
      Devise.clean_warden_config!
    end
  end

  test 'add new module using the helper method' do
    assert_nothing_raised(Exception) { Devise.add_module(:coconut) }
    assert_equal 1, Devise::ALL.select { |v| v == :coconut }.size
    assert_not Devise::STRATEGIES.include?(:coconut)
    assert_not defined?(Devise::Models::Coconut)
    Devise::ALL.delete(:coconut)

    assert_nothing_raised(Exception) { Devise.add_module(:banana, :strategy => true) }
    assert_equal 1, Devise::STRATEGIES.select { |v| v == :banana }.size
    Devise::ALL.delete(:banana)
    Devise::STRATEGIES.delete(:banana)

    assert_nothing_raised(Exception) { Devise.add_module(:kivi, :controller => :fruits) }
    assert_not_nil Devise::CONTROLLERS[:fruits]
    assert_equal 1, Devise::CONTROLLERS[:fruits].select { |v| v == :kivi }.size
    Devise::ALL.delete(:kivi)
    Devise::CONTROLLERS.delete(:fruits)

    assert_nothing_raised(Exception) { Devise.add_module(:authenticatable_again, :model => 'devise/model/authenticatable') }
    assert defined?(Devise::Models::AuthenticatableAgain)
  end
end
