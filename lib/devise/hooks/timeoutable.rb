# Each time a record is set we check whether it's session has already timed out
# or not, based on last request time. If so, the record is logged out and
# redirected to the sign in page. Also, each time the request comes and the
# record is set, we set the last request time inside it's scoped session to
# verify timeout in the following request.
Warden::Manager.after_set_user do |record, warden, options|
  if record.present? && record.respond_to?(:timeout?)
    scope = options[:scope]
    # Current record may have already be logged out by another hook.
    # For instance, Devise confirmable hook may have logged the record out.
    # TODO: is it possible to move this check to warden?
    # It should stop the hooks if the record is logged out by any of them.
    if warden.authenticated?(scope)
      last_request_at = warden.session(scope)['last_request_at']
      if record.timeout?(last_request_at)
        warden.logout(scope)
        throw :warden, :scope => scope, :message => :timeout
      end
      warden.session(scope)['last_request_at'] = Time.now.utc
    end
  end
end
