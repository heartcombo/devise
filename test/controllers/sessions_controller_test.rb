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
end
