# Adds RailsWarden Manager to Rails middleware stack, configuring default devise
# strategy and also the controller who will manage not authenticated users.
#
Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :devise
  manager.failure_app = SessionsController
end

# Configure RailsWarden to call new action inside failure controller when no
# user is authenticated.
#
RailsWarden.unauthenticated_action = 'new'

# Default strategy for signing in a user, based on his email and password.
# If no email and no password are present, no authentication is tryed.
#
Warden::Strategies.add(:devise) do

  # Validate params before authenticating a user. If both email and password are
  # not present, no authentication is attempted.
  #
  def valid?
    params[:session] ||= {}
    params[:session][:email].present? && params[:session][:password].present?
  end

  # Authenticate a user based on email and password params, returning to warden
  # success and the authenticated user if everything is okay. Otherwise tell
  # warden the authentication was failed.
  #
  def authenticate!
    if user = User.authenticate(params[:session][:email], params[:session][:password])
      success!(user)
    else
      fail!(I18n.t(:authentication_failed, :scope => [:devise, :sessions], :default => 'Invalid email or password'))
    end
  end
end
