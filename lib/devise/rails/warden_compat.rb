module Warden::Mixins::Common
  def request
    @request ||= env['action_controller.rescue.request']
  end

  def reset_session!
    raw_session.inspect # why do I have to inspect it to get it to clear?
    raw_session.clear
  end

  def response
    @response ||= env['action_controller.rescue.response']
  end
end

class Warden::SessionSerializer
  def serialize(record)
    [record.class, record.id]
  end

  def deserialize(keys)
    klass, id = keys
    klass.find(:first, :conditions => { :id => id })
  end
end

class ActionController::Request
  def reset_session
    session.destroy if session && session.respond_to?(:destroy)
    self.session = {}
  end
end

# Solve a bug in Rails where Set-Cookie is returning an array.
class Devise::CookieSanitizer
  SET_COOKIE = "Set-Cookie".freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    response = @app.call(env)
    headers = response[1]
    cookies = headers[SET_COOKIE]
    if cookies.respond_to?(:join)
      headers[SET_COOKIE] = cookies.join("\n").squeeze("\n")
    end
    response
  end
end

Rails.configuration.middleware.insert_after ActionController::Failsafe, Devise::CookieSanitizer

Warden::Manager.after_set_user :event => [:set_user, :authentication] do |record, warden, options|
  if options[:scope] && warden.authenticated?(options[:scope])
    request = warden.request
    backup = request.session.to_hash
    backup.delete(:session_id)
    request.reset_session
    request.session.update(backup)
  end
end
