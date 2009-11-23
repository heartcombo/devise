Warden::Manager.after_set_user do |record, warden, options|
  if record.present?
    scope = options[:scope]
    # Current record may have already be logged out by another hook.
    # For instance, Devise confirmable hook may have logged the record out.
    # TODO: move this verify to warden: he should stop the hooks if the record
    # is logged out by any of them.
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
