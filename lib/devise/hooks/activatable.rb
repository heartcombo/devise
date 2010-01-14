# Deny user access whenever his account is not active yet.
Warden::Manager.after_set_user do |record, warden, options|
  if record && record.respond_to?(:active?) && !record.active?
    scope = options[:scope]
    warden.logout(scope)

    # If winning strategy was set, this is being called after authenticate and
    # there is no need to force a redirect.
    if warden.winning_strategy
      warden.winning_strategy.fail!(record.inactive_message)
    else
      throw :warden, :scope => scope, :message => record.inactive_message
    end
  end
end
