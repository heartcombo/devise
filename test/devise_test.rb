require 'test_helper'

class Authenticable < ActiveRecord::Base
  acts_as_devisable
end

class Confirmable < ActiveRecord::Base
  acts_as_devisable :confirmable
end

class Recoverable < ActiveRecord::Base
  acts_as_devisable :recoverable
end

class Validatable < ActiveRecord::Base
  acts_as_devisable :validatable
end

class Devisable < ActiveRecord::Base
  acts_as_devisable :all
end

class DeviseTest < ActiveSupport::TestCase

  def include_authenticable_module?(mod)
    mod.included_modules.include?(Devise::Models::Authenticable)
  end

  def include_confirmable_module?(mod)
    mod.included_modules.include?(Devise::Models::Confirmable)
  end

  def include_recoverable_module?(mod)
    mod.included_modules.include?(Devise::Models::Recoverable)
  end

  def include_validatable_module?(mod)
    mod.included_modules.include?(Devise::Models::Validatable)
  end

  test 'acts as devisable should include by defaul authenticable only' do
    assert include_authenticable_module?(Authenticable)
    assert_not include_confirmable_module?(Authenticable)
    assert_not include_recoverable_module?(Authenticable)
    assert_not include_validatable_module?(Authenticable)
  end

  test 'acts as devisable should be able to add confirmable module only' do
    assert include_authenticable_module?(Confirmable)
    assert include_confirmable_module?(Confirmable)
    assert_not include_recoverable_module?(Confirmable)
    assert_not include_validatable_module?(Confirmable)
  end

  test 'acts as devisable should be able to add recoverable module only' do
    assert include_authenticable_module?(Recoverable)
    assert_not include_confirmable_module?(Recoverable)
    assert include_recoverable_module?(Recoverable)
    assert_not include_validatable_module?(Recoverable)
  end

  test 'acts as devisable should be able to add validatable module only' do
    assert include_authenticable_module?(Validatable)
    assert_not include_confirmable_module?(Validatable)
    assert_not include_recoverable_module?(Validatable)
    assert include_validatable_module?(Validatable)
  end

  test 'acts as devisable should be able to add all modules' do
    assert include_authenticable_module?(Devisable)
    assert include_confirmable_module?(Devisable)
    assert include_recoverable_module?(Devisable)
    assert include_validatable_module?(Devisable)
  end
end
