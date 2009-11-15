# Taken from RailsWarden, thanks to Hassox. http://github.com/hassox/rails_warden
module Warden::Mixins::Common
  def request
    return @request if @request
    if env['action_controller.rescue.request']
      @request = env['action_controller.rescue.request']
    else
      Rack::Request.new(env)
    end
  end

  def reset_session!
    raw_session.inspect # why do I have to inspect it to get it to clear?
    raw_session.clear
  end

  def response
    return @response if @response
    if env['action_controller.rescue.response']
      @response = env['action_controller.rescue.response']
    else
      Rack::Response.new(env)
    end
  end
end
