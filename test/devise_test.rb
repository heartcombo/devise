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
    assert_equal [:authenticatable], config.default_strategies
    assert_equal :user, config.default_scope
    assert config.silence_missing_strategies?
    assert config.silence_missing_serializers?
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
end
