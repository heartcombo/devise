require 'test_helper'

class Configurable < User
  devise :database_authenticatable, :encryptable, :confirmable, :rememberable, :timeoutable, :lockable,
         :stretches => 15, :pepper => 'abcdef', :confirm_within => 5.days,
         :remember_for => 7.days, :timeout_in => 15.minutes, :unlock_in => 10.days
end

class WithValidation < Admin
  devise :database_authenticatable, :validatable, :password_length => 2..6
end

class UserWithValidation < User
  validates_presence_of :username
end

class Several < Admin
  devise :validatable
  devise :lockable
end

class Inheritable < Admin
end

class ActiveRecordTest < ActiveSupport::TestCase
  def include_module?(klass, mod)
    klass.devise_modules.include?(mod) &&
    klass.included_modules.include?(Devise::Models::const_get(mod.to_s.classify))
  end

  def assert_include_modules(klass, *modules)
    modules.each do |mod|
      assert include_module?(klass, mod)
    end

    (Devise::ALL - modules).each do |mod|
      assert_not include_module?(klass, mod)
    end
  end

  test 'can cherry pick modules' do
    assert_include_modules Admin, :database_authenticatable, :registerable, :timeoutable, :recoverable, :lockable, :rememberable, :encryptable
  end

  if DEVISE_ORM == :active_record
    test 'validations options are not applied to late' do
      validators = WithValidation.validators_on :password
      length = validators.find { |v| v.kind == :length }
      assert_equal 2, length.options[:minimum]
      assert_equal 6, length.options[:maximum]
    end

    test 'validations are applied just once' do
      validators = Several.validators_on :password
      assert_equal 1, validators.select{ |v| v.kind == :length }.length
    end
  end

  test 'chosen modules are inheritable' do
    assert_include_modules Inheritable, :database_authenticatable, :registerable, :timeoutable, :recoverable, :lockable, :rememberable, :encryptable
  end

  test 'order of module inclusion' do
    correct_module_order   = [:database_authenticatable, :rememberable, :encryptable, :recoverable, :registerable, :lockable, :timeoutable]
    incorrect_module_order = [:database_authenticatable, :timeoutable, :registerable, :recoverable, :lockable, :encryptable, :rememberable]

    assert_include_modules Admin, *incorrect_module_order

    # get module constants from symbol list
    module_constants = correct_module_order.collect { |mod| Devise::Models::const_get(mod.to_s.classify) }

    # confirm that they adhere to the order in ALL
    # get included modules, filter out the noise, and reverse the order
    assert_equal module_constants, (Admin.included_modules & module_constants).reverse
  end

  test 'raise error on invalid module' do
    assert_raise NameError do
      # Mix valid an invalid modules.
      Configurable.class_eval { devise :database_authenticatable, :doesnotexit }
    end
  end

  test 'set a default value for stretches' do
    assert_equal 15, Configurable.stretches
  end

  test 'set a default value for pepper' do
    assert_equal 'abcdef', Configurable.pepper
  end

  test 'set a default value for confirm_within' do
    assert_equal 5.days, Configurable.confirm_within
  end

  test 'set a default value for remember_for' do
    assert_equal 7.days, Configurable.remember_for
  end

  test 'set a default value for timeout_in' do
    assert_equal 15.minutes, Configurable.timeout_in
  end

  test 'set a default value for unlock_in' do
    assert_equal 10.days, Configurable.unlock_in
  end

  test 'set null fields on migrations' do
    Admin.create!
  end
end
