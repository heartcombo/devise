class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    data = env["omniauth.auth"]
    session["devise.facebook_data"] = data["extra"]["user_hash"]
    render json: data
  end

  def sign_in_facebook
    user = User.to_adapter.find_first(email: 'user@test.com')
    user.remember_me = true
    sign_in user
    render text: ""
  end
end
