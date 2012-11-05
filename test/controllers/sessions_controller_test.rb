require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  tests Devise::SessionsController
  include Devise::TestHelpers

  test "#create works even with scoped views" do
    swap Devise, :scoped_views => true do
      request.env["devise.mapping"] = Devise.mappings[:user]
      post :create
      assert_equal 200, @response.status
      assert_template "users/sessions/new"
    end
  end

  test "#create delete the url stored in the session if the requested format is navigational" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.session["user_return_to"] = 'foo.bar'

    user = create_user
    user.confirm!
    post :create, :user => {
      :email => user.email,
      :password => user.password
    }

    assert_nil request.session["user_return_to"]
  end

  test "#create doesn't delete the url stored in the session if the requested format is not navigational" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.session["user_return_to"] = 'foo.bar'

    user = create_user
    user.confirm!
    post :create, :format => 'json', :user => {
      :email => user.email,
      :password => user.password
    }

    assert_equal 'foo.bar', request.session["user_return_to"]
  end

  test "#create doesn't raise exception after Warden authentication fails when TestHelpers included" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    post :create, :user => {
      :email => "nosuchuser@example.com",
      :password => "wevdude"
    }
    assert_equal 200, @response.status
    assert_template "devise/sessions/new"
  end

  test "#destroy doesn't set the flash if the requested format is not navigational" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    user = create_user
    user.confirm!
    post :create, :format => 'json', :user => {
      :email => user.email,
      :password => user.password
    }

    delete :destroy, :format => 'json'
    assert flash[:notice].blank?, "flash[:notice] should be blank, not #{flash[:notice].inspect}"
    assert_equal 204, @response.status
  end

  if defined?(ActiveRecord) && ActiveRecord::Base.respond_to?(:mass_assignment_sanitizer)
    test "#new doesn't raise mass-assignment exception even if sign-in key is attr_protected" do
      request.env["devise.mapping"] = Devise.mappings[:user]

      ActiveRecord::Base.mass_assignment_sanitizer = :strict
      User.class_eval { attr_protected :email }

      begin
        assert_nothing_raised ActiveModel::MassAssignmentSecurity::Error do
          get :new, :user => { :email => "allez viens!" }
        end
      ensure
        ActiveRecord::Base.mass_assignment_sanitizer = :logger
        User.class_eval { attr_accessible :email }
      end
    end
  end
end
