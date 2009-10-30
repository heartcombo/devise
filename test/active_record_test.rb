require 'test/test_helper'

class Authenticable < User
  devise
end

class Confirmable < User
  devise :confirmable
end

class Recoverable < User
  devise :recoverable
end

class Rememberable < User
  devise :rememberable
end

class Validatable < User
  devise :validatable
end

class Devisable < User
  devise :all
end

class Exceptable < User
  devise :all, :except => [:recoverable, :rememberable, :validatable]
end

class Configurable < User
  devise :all, :stretches => 15,
               :pepper => 'abcdef',
               :confirm_within => 5.days,
               :remember_for => 7.days
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
  end

  def assert_not_include_modules(klass, *modules)
    modules.each do |mod|
      assert_not include_module?(klass, mod)
    end
  end

  test 'include by default authenticatable only' do
    assert_include_modules Authenticable, :authenticatable
    assert_not_include_modules Authenticable, :confirmable, :recoverable, :rememberable, :validatable
  end

  test 'add confirmable module only' do
    assert_include_modules Confirmable, :authenticatable, :confirmable
    assert_not_include_modules Confirmable, :recoverable, :rememberable, :validatable
  end

  test 'add recoverable module only' do
    assert_include_modules Recoverable, :authenticatable, :recoverable
    assert_not_include_modules Recoverable, :confirmable, :rememberable, :validatable
  end

  test 'add rememberable module only' do
    assert_include_modules Rememberable, :authenticatable, :rememberable
    assert_not_include_modules Rememberable, :confirmable, :recoverable, :validatable
  end

  test 'add validatable module only' do
    assert_include_modules Validatable, :authenticatable, :validatable
    assert_not_include_modules Validatable, :confirmable, :recoverable, :rememberable
  end

  test 'add all modules' do
    assert_include_modules Devisable,
      :authenticatable, :confirmable, :recoverable, :rememberable, :validatable
  end

  test 'configure modules with except option' do
    assert_include_modules Exceptable, :authenticatable, :confirmable
    assert_not_include_modules Exceptable, :recoverable, :rememberable, :validatable
  end

  test 'set a default value for stretches' do
    assert_equal 15, Configurable.new.stretches
  end

  test 'set a default value for pepper' do
    assert_equal 'abcdef', Configurable.new.pepper
  end

  test 'set a default value for confirm_within' do
    assert_equal 5.days, Configurable.new.confirm_within
  end

  test 'set a default value for remember_for' do
    assert_equal 7.days, Configurable.new.remember_for
  end

  test 'set null fields on migrations' do
    Admin.create!
  end
end
