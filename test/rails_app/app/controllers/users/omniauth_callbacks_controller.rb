class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    data = env["omniauth.auth"]
    session["devise.facebook_data"] = data
    render :json => data
  end
end