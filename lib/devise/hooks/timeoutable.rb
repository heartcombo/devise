# Each time a record is set we check whether it's session has already timed out
# or not, based on last request time. If so, the record is logged out and
# redirected to the sign in page. Also, each time the request comes and the
# record is set, we set the last request time inside it's scoped session to
# verify timeout in the following request.
Warden::Manager.after_set_user do |record, warden, options|
  if record.present? && record.respond_to?(:timeout?)
    scope = options[:scope]
    # Record may have already been logged out by another hook (ie confirmable).
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
