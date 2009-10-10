# Taken from RailsWarden, thanks to Hassox. http://github.com/hassox/rails_warden
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

# Rails needs the action to be passed in with the params
Warden::Manager.before_failure do |env, opts|
  env['warden'].request.params['action'] = 'new'
  if request = env["action_controller.rescue.request"]
    request.params["action"] = 'new'
  end
end

# Session Serialization in.  This block determines how the user will
# be stored in the session.  If you're using a complex object like an
# ActiveRecord model, it is not a good idea to store the complete object.
# An ID is sufficient
Warden::Manager.serialize_into_session{ |user| [user.class, user.id] }

# Session Serialization out.  This block gets the user out of the session.
# It should be the reverse of serializing the object into the session
Warden::Manager.serialize_from_session do |klass, id|
  klass = case klass
  when Class
    klass
  when String, Symbol
    klass.to_s.classify.constantize
  end
  klass.find(id)
end

# Adds RailsWarden Manager to Rails middleware stack, configuring default devise
# strategy and also the controller who will manage not authenticated users.
#
Rails.configuration.middleware.use Warden::Manager do |manager|
  manager.default_strategies :devise
  manager.failure_app = SessionsController
end

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
    if user = Devise.resource_class(request.path).authenticate(params[:session][:email], params[:session][:password])
      success!(user)
    else
      fail!(I18n.t(:authentication_failed, :scope => [:devise, :sessions], :default => 'Invalid email or password'))
    end
  end
end
