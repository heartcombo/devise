require 'test_helper'

module Devise
  def self.yield_and_restore
    @@warden_configured = nil
    c, b = @@warden_config, @@warden_config_block
    yield
  ensure
    @@warden_config, @@warden_config_block = c, b
  end
end

class DeviseTest < ActiveSupport::TestCase
  test 'model options can be configured through Devise' do
    swap Devise, :allow_unconfirmed_access_for => 113, :pepper => "foo" do
      assert_equal 113, Devise.allow_unconfirmed_access_for
      assert_equal "foo", Devise.pepper
    end
  end

  test 'setup block yields self' do
    Devise.setup do |config|
      assert_equal Devise, config
    end
  end

  test 'stores warden configuration' do
    assert_kind_of Devise::Delegator, Devise.warden_config.failure_app
    assert_equal :user, Devise.warden_config.default_scope
  end

  test 'warden manager user configuration through a block' do
    Devise.yield_and_restore do
      @executed = false
      Devise.warden do |config|
        @executed = true
        assert_kind_of Warden::Config, config
      end

      Devise.configure_warden!
      assert @executed
    end
  end

  test 'add new module using the helper method' do
    assert_nothing_raised(Exception) { Devise.add_module(:coconut) }
    assert_equal 1, Devise::ALL.select { |v| v == :coconut }.size
    assert_not Devise::STRATEGIES.include?(:coconut)
    assert_not defined?(Devise::Models::Coconut)
    Devise::ALL.delete(:coconut)

    assert_nothing_raised(Exception) { Devise.add_module(:banana, :strategy => :fruits) }
    assert_equal :fruits, Devise::STRATEGIES[:banana]
    Devise::ALL.delete(:banana)
    Devise::STRATEGIES.delete(:banana)

    assert_nothing_raised(Exception) { Devise.add_module(:kivi, :controller => :fruits) }
    assert_equal :fruits, Devise::CONTROLLERS[:kivi]
    Devise::ALL.delete(:kivi)
    Devise::CONTROLLERS.delete(:kivi)
  end
  
  test 'should complain when comparing empty or different sized passes' do
    [nil, ""].each do |empty|
      assert_not Devise.secure_compare(empty, "something")
      assert_not Devise.secure_compare("something", empty)
      assert_not Devise.secure_compare(empty, empty)
    end
    assert_not Devise.secure_compare("size_1", "size_four")
  end
  
end
