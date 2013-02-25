module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  # This is called internally by Warden on logout
  def reset_session!
    request.reset_session
  end

  def cookies
    request.cookie_jar
  end
end
