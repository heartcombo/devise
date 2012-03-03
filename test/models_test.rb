require 'test_helper'

class Configurable < User
  devise :database_authenticatable, :encryptable, :confirmable, :rememberable, :timeoutable, :lockable,
         :stretches => 15, :pepper => 'abcdef', :allow_unconfirmed_access_for => 5.days,
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
    assert_include_modules Admin, :database_authenticatable, :registerable, :timeoutable, :recoverable, :lockable, :encryptable, :confirmable
  end

  test 'validations options are not applied too late' do
    validators = WithValidation.validators_on :password
    length = validators.find { |v| v.kind == :length }
    assert_equal 2, length.options[:minimum]
    assert_equal 6, length.options[:maximum]
  end

  test 'validations are applied just once' do
    validators = Several.validators_on :password
    assert_equal 1, validators.select{ |v| v.kind == :length }.length
  end

  test 'chosen modules are inheritable' do
    assert_include_modules Inheritable, :database_authenticatable, :registerable, :timeoutable, :recoverable, :lockable, :encryptable, :confirmable
  end

  test 'order of module inclusion' do
    correct_module_order   = [:database_authenticatable, :encryptable, :recoverable, :registerable, :confirmable, :lockable, :timeoutable]
    incorrect_module_order = [:database_authenticatable, :timeoutable, :registerable, :recoverable, :lockable, :encryptable, :confirmable]

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

  test 'set a default value for allow_unconfirmed_access_for' do
    assert_equal 5.days, Configurable.allow_unconfirmed_access_for
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

class CheckFieldsTest < ActiveSupport::TestCase
  test 'checks if the class respond_to the required fields' do
    Player = Class.new do
      extend Devise::Models

      def self.before_validation(instance)
      end

      devise :database_authenticatable

      attr_accessor :encrypted_password, :email
    end

    assert_nothing_raised Devise::Models::MissingAttribute do
      Devise::Models.check_fields!(Player)
    end
  end

  test 'raises Devise::Models::MissingAtrribute and shows the missing attribute if the class doesn\'t respond_to one of the attributes' do
    Clown = Class.new do
      extend Devise::Models

      def self.before_validation(instance)
      end

      devise :database_authenticatable

      attr_accessor :encrypted_password
    end

    assert_raise_with_message Devise::Models::MissingAttribute, "The following attribute(s) is (are) missing on your model: email" do
      Devise::Models.check_fields!(Clown)
    end
  end

  test 'raises Devise::Models::MissingAtrribute with all the missing attributes if there is more than one' do
    Magician = Class.new do
      extend Devise::Models

      def self.before_validation(instance)
      end

      devise :database_authenticatable
    end

    exception = assert_raise_with_message Devise::Models::MissingAttribute, "The following attribute(s) is (are) missing on your model: encrypted_password, email" do
      Devise::Models.check_fields!(Magician)
    end
  end

  test "doesn't raises a NoMethodError exception when the module doesn't have a required_field(klass) class method" do
     Driver = Class.new do
      extend Devise::Models

      def self.before_validation(instance)
      end

      devise :database_authenticatable
    end

    swap_module_method_existence Devise::Models::DatabaseAuthenticatable, :required_fields do
      assert_deprecated "DEPRECATION WARNING: The module database_authenticatable doesn't implement self.required_fields(klass). Devise uses required_fields to warn developers of any missing fields in their models. Please implement database_authenticatable.required_fields(klass) that returns an array of symbols with the required fields." do
        Devise::Models.check_fields!(Driver)
      end
    end
  end
end
