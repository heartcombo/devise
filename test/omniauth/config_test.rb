require 'test_helper'

class OmniAuthConfigTest < ActiveSupport::TestCase
  def self.context(name, &block)
    instance_eval(&block)
  end

  setup do
    $: << File.dirname(__FILE__)
  end

  context 'Devise::OmniAuth::Config#strategy_name' do
    test 'returns provider if no options given' do
      config = Devise::OmniAuth::Config.new :facebook, [{}]
      assert_equal :facebook, config.strategy_name
    end
    test 'returns provider if no name option given' do
      config = Devise::OmniAuth::Config.new :facebook, [{ :other => :option }]
      assert_equal :facebook, config.strategy_name
    end
    test 'returns name option' do
      config = Devise::OmniAuth::Config.new :facebook, [{ :name => :github }]
      assert_equal :github, config.strategy_name
    end
  end

  context 'Devise::OmniAuth::Config#strategy_class' do
    test "finds contrib strategies" do
      config = Devise::OmniAuth::Config.new :facebook, [{}]
      assert_equal OmniAuth::Strategies::Facebook, config.strategy_class
    end
    test "finds the strategy in OmniAuth's list by name" do
      NamedTestStrategy = Class.new
      NamedTestStrategy.send :include, OmniAuth::Strategy
      NamedTestStrategy.option :name, :the_one

      config = Devise::OmniAuth::Config.new :the_one, [{}]
      assert_equal NamedTestStrategy, config.strategy_class
    end
    test "finds the strategy in OmniAuth's list by class name" do
      UnNamedTestStrategy = Class.new
      UnNamedTestStrategy.send :include, OmniAuth::Strategy

      config = Devise::OmniAuth::Config.new :un_named_test_strategy, [{}]
      assert_equal UnNamedTestStrategy, config.strategy_class
    end
    test 'attempts to load an as-yet not loaded plugin' do
      config = Devise::OmniAuth::Config.new :my_strategy, [{}]
      config_class = config.strategy_class
      assert_equal MyStrategy, config_class
    end
    test 'allows the user to define a custom require path' do
      config = Devise::OmniAuth::Config.new :my_other_strategy, [{:require => 'my_other_strategy'}]
      config_class = config.strategy_class
      assert_equal MyOtherStrategy, config_class
    end
  end
end