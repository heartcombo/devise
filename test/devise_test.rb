require 'test_helper'

module Devise
  def self.yield_and_restore
    @@warden_configured = nil
    c, b = @@warden_config, @@warden_config_blocks
    yield
  ensure
    @@warden_config, @@warden_config_blocks = c, b
  end
end

class DeviseTest < ActiveSupport::TestCase
  test 'bcrypt on the class' do
    password = "super secret"
    klass    = Struct.new(:pepper, :stretches).new("blahblah", 2)
    hash     = Devise::Encryptor.digest(klass, password)
    assert_equal ::BCrypt::Password.create(hash), hash

    klass    = Struct.new(:pepper, :stretches).new("bla", 2)
    hash     = Devise::Encryptor.digest(klass, password)
    assert_not_equal ::BCrypt::Password.new(hash), hash
  end

  test 'model options can be configured through Devise' do
    swap Devise, allow_unconfirmed_access_for: 113, pepper: "foo" do
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
      executed = false
      Devise.warden do |config|
        executed = true
        assert_kind_of Warden::Config, config
      end

      Devise.configure_warden!
      assert executed
    end
  end

  test 'warden manager user configuration through multiple blocks' do
    Devise.yield_and_restore do
      executed = 0

      3.times do
        Devise.warden { |config| executed += 1 }
      end

      Devise.configure_warden!
      assert_equal 3, executed
    end
  end

  test 'add new module using the helper method' do
    assert_nothing_raised(Exception) { Devise.add_module(:coconut) }
    assert_equal 1, Devise::ALL.select { |v| v == :coconut }.size
    assert_not Devise::STRATEGIES.include?(:coconut)
    assert_not defined?(Devise::Models::Coconut)
    Devise::ALL.delete(:coconut)

    assert_nothing_raised(Exception) { Devise.add_module(:banana, strategy: :fruits) }
    assert_equal :fruits, Devise::STRATEGIES[:banana]
    Devise::ALL.delete(:banana)
    Devise::STRATEGIES.delete(:banana)

    assert_nothing_raised(Exception) { Devise.add_module(:kivi, controller: :fruits) }
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

  test 'Devise.email_regexp should match valid email addresses' do
    valid_emails = ["test@example.com", "jo@jo.co", "f4$_m@you.com", "testing.example@example.com.ua"]
    non_valid_emails = ["rex", "test@go,com", "test user@example.com", "test_user@example server.com", "test_user@example.com."]

    valid_emails.each do |email|
      assert_match Devise.email_regexp, email
    end
    non_valid_emails.each do |email|
      assert_no_match Devise.email_regexp, email
    end
  end
end
