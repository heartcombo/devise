require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  tests Devise::PasswordsController
  include Devise::TestHelpers

  setup :setup_for_user

  test "#create" do    
    user = User.create!(:email => 'user@example.com', :password => 'password')

    post :create, :user => { :email => "user@example.com" }

    assert_equal I18n.t('devise.passwords.send_instructions'), flash[:notice]
    assert_successful_create_redirect
    assert ActionMailer::Base.deliveries.present?
  end

  test "#create fails when no such user" do    
    post :create, :user => { :email => "nosuchuser@example.com" }

    assert_response :success
    assert_template "devise/passwords/new"
    assert ActionMailer::Base.deliveries.empty?
  end

  test "#create when paranoid and no such user" do
    swap Devise, :paranoid => true do
      post :create, :user => { :email => "nosuchuser@example.com" }

      assert_equal I18n.t('devise.passwords.send_paranoid_instructions'), flash[:notice]
      assert_successful_create_redirect
      assert ActionMailer::Base.deliveries.empty?
    end
  end

  test "#create when paranoid and user exists" do
    swap Devise, :paranoid => true do
      user = User.create!(:email => 'user@example.com', :password => 'password')

      post :create, :user => { :email => "user@example.com" }

      assert_equal I18n.t('devise.passwords.send_paranoid_instructions'), flash[:notice]
      assert_successful_create_redirect
      assert ActionMailer::Base.deliveries.present?
    end
  end
  
  protected

  def setup_for_user
    ActionMailer::Base.deliveries = []
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  def assert_successful_create_redirect
    assert_redirected_to @controller.send(:after_sending_reset_password_instructions_path_for, :user)
  end

end
