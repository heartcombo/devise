# Each time a record is fetched from a session we check whether its
# session has already timed out or not, based on last request time.
# If so, the record is logged out and redirected to the sign in page.
# Also, each time the record is set, we set the last request time
# inside its scoped session to verify timeout in the following request.

Warden::Manager.after_fetch do |record, warden, options|
  scope = options[:scope]
  env   = warden.request.env

  if record && record.respond_to?(:timedout?) && warden.authenticated?(scope) && options[:store] != false && !env['devise.skip_timeout']
    last_request_at = warden.session(scope)['last_request_at']

    if record.timedout?(last_request_at)
      warden.logout(scope)
      if record.respond_to?(:expire_auth_token_on_timeout) && record.expire_auth_token_on_timeout
        record.reset_authentication_token!
      end
      throw :warden, :scope => scope, :message => :timeout
    end
  end
end

Warden::Manager.after_set_user do |record, warden, options|
  scope = options[:scope]
  env   = warden.request.env

  if record && record.respond_to?(:timedout?) && warden.authenticated?(scope) && options[:store] != false && !env['devise.skip_trackable']
    warden.session(scope)['last_request_at'] = Time.now.utc
  end
end

