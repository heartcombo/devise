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
