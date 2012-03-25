require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  tests Devise::SessionsController
  include Devise::TestHelpers

  test "#create doesn't raise exception after Warden authentication fails when TestHelpers included" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    post :create, :user => {
      :email => "nosuchuser@example.com",
      :password => "wevdude"
    }
    assert_equal 200, @response.status
    assert_template "devise/sessions/new"
  end
  
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
