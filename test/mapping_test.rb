require 'test_helper'

class MappingTest < ActiveSupport::TestCase

  test 'store options' do
    mapping = Devise.mappings[:user]
    assert_equal User,                mapping.to
    assert_equal User.devise_modules, mapping.modules
    assert_equal :users,              mapping.as
  end

  test 'allows as to be given' do
    assert_equal :admin_area, Devise.mappings[:admin].as
  end

  test 'allows custom scope to be given' do
    assert_equal :accounts, Devise.mappings[:manager].as
  end

  test 'allows a controller depending on the mapping' do
    allowed = Devise.mappings[:user].allowed_controllers
    assert allowed.include?("devise/sessions")
    assert allowed.include?("devise/confirmations")
    assert allowed.include?("devise/passwords")

    allowed = Devise.mappings[:admin].allowed_controllers
    assert allowed.include?("sessions")
    assert_not allowed.include?("devise/confirmations")
    assert_not allowed.include?("devise/unlocks")
  end

  test 'has strategies depending on the model declaration' do
    assert_equal [:rememberable, :token_authenticatable,
     :http_authenticatable, :authenticatable], Devise.mappings[:user].strategies
    assert_equal [:authenticatable], Devise.mappings[:admin].strategies
  end

  test 'find mapping by path' do
    assert_nil   Devise::Mapping.find_by_path("/foo/bar")
    assert_equal Devise.mappings[:user], Devise::Mapping.find_by_path("/users/session")
  end

  test 'find mapping by customized path' do
    assert_equal Devise.mappings[:admin], Devise::Mapping.find_by_path("/admin_area/session")
  end

  test 'find scope for a given object' do
    assert_equal :user, Devise::Mapping.find_scope!(User)
    assert_equal :user, Devise::Mapping.find_scope!(:user)
    assert_equal :user, Devise::Mapping.find_scope!(User.new)
  end

  test 'find scope works with single table inheritance' do
    assert_equal :user, Devise::Mapping.find_scope!(Class.new(User))
    assert_equal :user, Devise::Mapping.find_scope!(Class.new(User).new)
  end

  test 'find scope raises an error if cannot be found' do
    assert_raise RuntimeError do
      Devise::Mapping.find_scope!(String)
    end
  end

  test 'return default path names' do
    mapping = Devise.mappings[:user]
    assert_equal 'sign_in',      mapping.path_names[:sign_in]
    assert_equal 'sign_out',     mapping.path_names[:sign_out]
    assert_equal 'password',     mapping.path_names[:password]
    assert_equal 'confirmation', mapping.path_names[:confirmation]
    assert_equal 'sign_up',      mapping.path_names[:sign_up]
    assert_equal 'unlock',       mapping.path_names[:unlock]
  end

  test 'allow custom path names to be given' do
    mapping = Devise.mappings[:manager]
    assert_equal 'login',        mapping.path_names[:sign_in]
    assert_equal 'logout',       mapping.path_names[:sign_out]
    assert_equal 'secret',       mapping.path_names[:password]
    assert_equal 'verification', mapping.path_names[:confirmation]
    assert_equal 'register',     mapping.path_names[:sign_up]
    assert_equal 'unblock',      mapping.path_names[:unlock]
  end

  test 'has an empty path as default path prefix' do
    mapping = Devise.mappings[:user]
    assert_equal '/', mapping.path_prefix
  end

  test 'allow path prefix to be configured' do
    mapping = Devise.mappings[:manager]
    assert_equal '/:locale/', mapping.path_prefix
  end

  test 'retrieve as from the proper position' do
    assert_equal 1, Devise.mappings[:user].as_position
    assert_equal 2, Devise.mappings[:manager].as_position
  end

  test 'path is returned with path prefix and as' do
    assert_equal '/users', Devise.mappings[:user].path
    assert_equal '/:locale/accounts', Devise.mappings[:manager].path
  end

  test 'magic predicates' do
    mapping = Devise.mappings[:user]
    assert mapping.authenticatable?
    assert mapping.confirmable?
    assert mapping.recoverable?
    assert mapping.rememberable?
    assert mapping.registerable?

    mapping = Devise.mappings[:admin]
    assert mapping.authenticatable?
    assert mapping.recoverable?
    assert_not mapping.confirmable?
    assert_not mapping.lockable?
    assert_not mapping.rememberable?
  end
end
