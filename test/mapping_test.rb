require 'test/test_helper'

class MappingTest < ActiveSupport::TestCase

  test 'store options' do
    mapping = Devise.mappings[:user]

    assert_equal User,                mapping.to
    assert_equal User.devise_modules, mapping.for
    assert_equal :users,              mapping.as
  end

  test 'allows as to be given' do
    assert_equal :admin_area, Devise.mappings[:admin].as
  end

  test 'allow custom scope to be given' do
    assert_equal :accounts, Devise.mappings[:manager].as
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

  test 'find mapping by path' do
    assert_nil   Devise::Mapping.find_by_path("/foo/bar")
    assert_equal Devise.mappings[:user], Devise::Mapping.find_by_path("/users/session")
  end

  test 'find mapping by customized path' do
    assert_equal Devise.mappings[:admin], Devise::Mapping.find_by_path("/admin_area/session")
  end

  test 'find mapping by class' do
    assert_nil Devise::Mapping.find_by_class(String)
    assert_equal Devise.mappings[:user], Devise::Mapping.find_by_class(User)
  end

  test 'find mapping by class works with single table inheritance' do
    klass = Class.new(User)
    assert_equal Devise.mappings[:user], Devise::Mapping.find_by_class(klass)
  end

  test 'find scope for a given object' do
    assert_equal :user, Devise::Mapping.find_scope!(User)
    assert_equal :user, Devise::Mapping.find_scope!(:user)
    assert_equal :user, Devise::Mapping.find_scope!(User.new)
  end

  test 'find scope raises an error if cannot be found' do
    assert_raise RuntimeError do
      Devise::Mapping.find_scope!(String)
    end
  end

  test 'return default path names' do
    mapping = Devise.mappings[:user]
    assert_equal 'sign_in', mapping.path_names[:sign_in]
    assert_equal 'sign_out', mapping.path_names[:sign_out]
    assert_equal 'password', mapping.path_names[:password]
    assert_equal 'confirmation', mapping.path_names[:confirmation]
  end

  test 'allow custom path names to be given' do
    mapping = Devise.mappings[:manager]
    assert_equal 'login', mapping.path_names[:sign_in]
    assert_equal 'logout', mapping.path_names[:sign_out]
    assert_equal 'secret', mapping.path_names[:password]
    assert_equal 'verification', mapping.path_names[:confirmation]
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

  test 'raw path is returned' do
    assert_equal '/users', Devise.mappings[:user].raw_path
    assert_equal '/:locale/accounts', Devise.mappings[:manager].raw_path
  end
  
  test 'raw path adds in the relative_url_root' do
    swap ActionController::Base, :relative_url_root => '/abc' do
      assert_equal '/abc/users', Devise.mappings[:user].raw_path
    end
  end

  test 'raw path deals with a nil relative_url_root' do
    swap ActionController::Base, :relative_url_root => nil do
      assert_equal '/users', Devise.mappings[:user].raw_path
    end
  end

  test 'parsed path is returned' do
    begin
      Devise.default_url_options {{ :locale => I18n.locale }}
      assert_equal '/users', Devise.mappings[:user].parsed_path
      assert_equal '/en/accounts', Devise.mappings[:manager].parsed_path
    ensure
      Devise.default_url_options {{ }}
    end
  end
  
  test 'parsed path deals with non-standard relative_url_roots' do
    swap ActionController::Base, :relative_url_root => "/abc" do
      assert_equal '/abc/users', Devise.mappings[:user].parsed_path
    end
  end
  
  test 'should have default route options' do
    assert_equal({}, Devise.mappings[:user].route_options)
  end

  test 'should allow passing route options to devise routes' do
    assert_equal({ :requirements => { :extra => 'value' } }, Devise.mappings[:manager].route_options)
  end

  test 'magic predicates' do
    mapping = Devise.mappings[:user]
    assert mapping.authenticatable?
    assert mapping.confirmable?
    assert mapping.recoverable?
    assert mapping.rememberable?

    mapping = Devise.mappings[:admin]
    assert mapping.authenticatable?
    assert_not mapping.confirmable?
    assert_not mapping.recoverable?
    assert_not mapping.rememberable?
  end
end
