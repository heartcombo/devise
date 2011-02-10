if DEVISE_ORM == :mongoid

  require 'test_helper'

  class User2
    include Mongoid::Document
    devise :database_authenticatable
  end

  class User3
    include Mongoid::Document
    devise :database_authenticatable, :authentication_keys => [:username, :email]
   end

  class User4
    include Mongoid::Document
    devise :database_authenticatable, :authentication_keys => [:username]
  end

  class SchemaTest < ActiveSupport::TestCase
    test 'should create an email field if there are no custom authentication keys' do
      assert_not_equal User2.fields['email'], nil
    end

    test 'should create an email field if there are custom authentication keys and they include email' do
      assert_not_equal User3.fields['email'], nil
    end

    test 'should not create an email field if there are custom authentication keys they don\'t include email' do
      assert_equal User4.fields['email'], nil
    end
  end
end
