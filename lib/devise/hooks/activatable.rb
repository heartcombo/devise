# Deny user access whenever his account is not active yet.
Warden::Manager.after_set_user do |record, warden, options|
  if record && record.respond_to?(:active?) && !record.active?
    scope = options[:scope]
    warden.logout(scope)
    throw :warden, :scope => scope, :message => record.inactive_message
  end
end
