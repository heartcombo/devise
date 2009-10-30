begin
  require 'warden'
rescue
  gem 'warden'
  require 'warden'
end

# Taken from RailsWarden, thanks to Hassox. http://github.com/hassox/rails_warden
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

  # Proxy to request cookies
  def cookies
    request.cookies
  end
end

# Session Serialization in. This block determines how the user will be stored
# in the session. If you're using a complex object like an ActiveRecord model,
# it is not a good idea to store the complete object. An ID is sufficient.
Warden::Manager.serialize_into_session{ |user| [user.class, user.id] }

# Session Serialization out. This block gets the user out of the session.
# It should be the reverse of serializing the object into the session
Warden::Manager.serialize_from_session do |klass, id|
  klass.find(id)
end

# Be a good citizen and always set the controller action, even if Devise is
# never calling the failure app through warden.
Warden::Manager.before_failure do |env, opts|
  env['warden'].request.params['action'] = 'new'
end

# Setup devise strategies for Warden
require 'devise/strategies/base'

# Adds Warden Manager to Rails middleware stack, configuring default devise
# strategy and also the controller who will manage not authenticated users.
Rails.configuration.middleware.use Warden::Manager do |manager|
  manager.default_strategies :rememberable, :authenticatable
  manager.failure_app = Devise::Failure
  manager.silence_missing_strategies!
end
