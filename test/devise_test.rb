require 'test/test_helper'

module Devise
  def self.clean_warden_config!
    @warden_config = nil 
  end
end

class DeviseTest < ActiveSupport::TestCase
  class MockManager
    attr_accessor :failure_app
    attr_reader :default_strategies, :silence_missing_strategies

    def silence_missing_strategies!
      @silence_missing_strategies = true
    end

    def default_strategies(*args)
      if args.empty?
        @default_strategies
      else
        @default_strategies = args
      end
    end
  end

  test 'DeviseMailer.sender can be configured through Devise' do
    swap DeviseMailer, :sender => "foo@bar" do
      assert_equal "foo@bar", DeviseMailer.sender
      Devise.mailer_sender = "bar@foo"
      assert_equal "bar@foo", DeviseMailer.sender
    end
  end

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
    manager = MockManager.new
    Devise.configure_warden_manager(manager)

    assert_equal Devise::Failure, manager.failure_app
    assert_equal [:authenticatable], manager.default_strategies
    assert manager.silence_missing_strategies
  end

  test 'warden manager user configuration through a block' do
    begin
      @executed = false
      Devise.warden do |manager|
        @executed = true
        assert_kind_of MockManager, manager
      end

      manager = MockManager.new
      Devise.configure_warden_manager(manager)
      assert @executed
    ensure
      Devise.clean_warden_config!
    end
  end
end
