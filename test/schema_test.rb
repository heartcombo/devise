require 'test_helper'

class SchemaTest < ActiveSupport::TestCase
  if DEVISE_ORM == :mongoid 
    test 'should create an email field if there are no custom authentication keys' do
      eval "class User2; include Mongoid::Document; devise :database_authenticatable; end"
      assert_not_equal User2.fields['email'], nil
    end

    test 'should create an email field if there are custom authentication keys and they include email' do
      eval "class User3; include Mongoid::Document; devise :database_authenticatable, :authentication_keys => [:username, :email]; end"
      assert_not_equal User3.fields['email'], nil
    end
    
    test 'should not create an email field if there are custom authentication keys they don\'t include email' do
      eval "class User4; include Mongoid::Document; devise :database_authenticatable, :authentication_keys => [:usernames]; end"
      assert_equal User4.fields['email'], nil
      assert_equal User4.fields['username'], nil
    end
  end
end
