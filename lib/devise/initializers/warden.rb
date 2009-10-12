# Taken from RailsWarden, thanks to Hassox.
# http://github.com/hassox/rails_warden
#
module Warden::Mixins::Common
  # Gets the rails request object by default if it's available
  def request
    return @request if @request
    if env['action_controller.rescue.request']
      @request = env['action_controller.rescue.request']
    else
      Rack::Request.new(env)
    end
  end

  def raw_session
    request.session
  end

  def reset_session!
    raw_session.inspect # why do I have to inspect it to get it to clear?
    raw_session.clear
  end
end

# Session Serialization in. This block determines how the user will be stored
# in the session. If you're using a complex object like an ActiveRecord model,
# it is not a good idea to store the complete object. An ID is sufficient.
#
Warden::Manager.serialize_into_session{ |user| [user.class, user.id] }

# Session Serialization out. This block gets the user out of the session.
# It should be the reverse of serializing the object into the session
#
Warden::Manager.serialize_from_session do |klass, id|
  klass.find(id)
end

# Default strategy for signing in a user, based on his email and password.
# If no email and no password are present, no authentication is tryed.
#
Warden::Strategies.add(:devise) do

  def valid?
    raise "You need to give a scope for Devise authentication" unless scope
    raise "You need to give a valid Devise mapping"            unless @mapping = Devise.mappings[scope]
    true
  end

  # Authenticate a user based on email and password params, returning to warden
  # success and the authenticated user if everything is okay. Otherwise redirect
  # to login page.
  #
  def authenticate!
    if valid_session? && resource = @mapping.to.authenticate(session)
      success!(resource)
    else
      redirect!("/#{@mapping.as}/session/new", :message => :unauthenticated)
    end
  end

  # Find the session for the current mapping.
  #
  def session
    @session ||= request.params[:session]
  end

  # Check for the right keys.
  #
  def valid_session?
    session && session[:email].present? && session[:password].present?
  end

end

# Adds Warden Manager to Rails middleware stack, configuring default devise
# strategy and also the controller who will manage not authenticated users.
#
Rails.configuration.middleware.use Warden::Manager do |manager|
  manager.default_strategies :devise
  manager.failure_app = SessionsController
end
