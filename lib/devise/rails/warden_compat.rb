module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  # Deprecate: Remove this check once we move to Rails 4 only.
  NULL_STORE =
    defined?(ActionController::RequestForgeryProtection::ProtectionMethods::NullSession::NullSessionHash) ?
      ActionController::RequestForgeryProtection::ProtectionMethods::NullSession::NullSessionHash : nil

  def reset_session!
    # Calling reset_session on NULL_STORE causes it fail.
    # This is a bug that needs to be fixed in Rails.
    unless NULL_STORE && request.session.is_a?(NULL_STORE)
      request.reset_session
    end
  end

  def cookies
    request.cookie_jar
  end
end
