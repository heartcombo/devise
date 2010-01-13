require 'test/test_helper'

class Authenticatable < User
  devise :authenticatable
end

class Confirmable < User
  devise :authenticatable, :confirmable
end

class Recoverable < User
  devise :authenticatable, :recoverable
end

class Rememberable < User
  devise :authenticatable, :rememberable
end

class Trackable < User
  devise :authenticatable, :trackable
end

class Timeoutable < User
  devise :authenticatable, :timeoutable
end

class Lockable < User
  devise :authenticatable, :lockable
end

class IsValidatable < User
  devise :authenticatable, :validatable
end

class Devisable < User
  devise :all
end

class Exceptable < User
  devise :all, :except => [:recoverable, :rememberable, :validatable, :lockable]
end

class Configurable < User
  devise :all, :timeoutable, :stretches => 15,
                             :pepper => 'abcdef',
                             :confirm_within => 5.days,
                             :remember_for => 7.days,
                             :timeout_in => 15.minutes
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

  test 'add authenticatable module only' do
    assert_include_modules Authenticatable, :authenticatable
  end

  test 'add confirmable module only' do
    assert_include_modules Confirmable, :authenticatable, :confirmable
  end

  test 'add recoverable module only' do
    assert_include_modules Recoverable, :authenticatable, :recoverable
  end

  test 'add rememberable module only' do
    assert_include_modules Rememberable, :authenticatable, :rememberable
  end

  test 'add trackable module only' do
    assert_include_modules Trackable, :authenticatable, :trackable
  end

  test 'add timeoutable module only' do
    assert_include_modules Timeoutable, :authenticatable, :timeoutable
  end

  test 'add lockable module only' do
    assert_include_modules Lockable, :authenticatable, :lockable
  end

  test 'add validatable module only' do
    assert_include_modules IsValidatable, :authenticatable, :validatable
  end

  test 'add all modules' do
    assert_include_modules Devisable,
      :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable
  end

  test 'configure modules with except option' do
    assert_include_modules Exceptable, :authenticatable, :confirmable, :trackable
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

  test 'set null fields on migrations' do
    Admin.create!
  end
end
