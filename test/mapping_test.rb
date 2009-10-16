require 'test/test_helper'

class MapTest < ActiveSupport::TestCase

  test 'store options' do
    mapping = Devise.mappings[:user]

    assert_equal User,                mapping.to
    assert_equal User.devise_modules, mapping.for
    assert_equal :users,              mapping.as
  end

  test 'allows as to be given' do
    assert_equal :admin_area, Devise.mappings[:admin].as
  end

  test 'allows a controller depending on the mapping' do
    mapping = Devise.mappings[:user]
    assert mapping.allows?(:sessions)
    assert mapping.allows?(:confirmations)
    assert mapping.allows?(:passwords)

    mapping = Devise.mappings[:admin]
    assert mapping.allows?(:sessions)
    assert_not mapping.allows?(:confirmations)
    assert_not mapping.allows?(:passwords)
  end

  test 'return mapping by path' do
    assert_nil   Devise.find_mapping_by_path("/foo/bar")
    assert_equal Devise.mappings[:user], Devise.find_mapping_by_path("/users/session")
  end

  test 'return mapping by customized path' do
    assert_equal Devise.mappings[:admin], Devise.find_mapping_by_path("/admin_area/session")
  end

  test 'return default path names' do
    mapping = Devise.mappings[:user]
    assert_equal 'sign_in', mapping.path_names[:sign_in]
    assert_equal 'sign_out', mapping.path_names[:sign_out]
    assert_equal 'password', mapping.path_names[:password]
    assert_equal 'confirmation', mapping.path_names[:confirmation]
  end

  test 'allow custom path names to be given' do
    mapping = Devise.mappings[:account]
    assert_equal 'login', mapping.path_names[:sign_in]
    assert_equal 'logout', mapping.path_names[:sign_out]
    assert_equal 'secret', mapping.path_names[:password]
    assert_equal 'verification', mapping.path_names[:confirmation]
  end

  test 'magic predicates' do
    mapping = Devise.mappings[:user]
    assert mapping.authenticable?
    assert mapping.confirmable?
    assert mapping.recoverable?

    mapping = Devise.mappings[:admin]
    assert mapping.authenticable?
    assert_not mapping.confirmable?
    assert_not mapping.recoverable?
  end
end
