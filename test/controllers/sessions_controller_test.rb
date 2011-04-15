require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  tests Devise::SessionsController
  include Devise::TestHelpers

  test "#create doesn't raise exception after Warden authentication fails " \
     + "when TestHelpers included" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    assert_nothing_raised(NoMethodError) do
      post :create, :user => {
        :email => "nosuchuser@example.com",
        :password => "wevdude"
      }
    end
  end
end
