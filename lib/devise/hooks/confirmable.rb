# Each time the user is set we verify if it is still able to really sign in.
# This is done by checking the time frame the user is able to sign in without
# confirming it's account. If the user has not confirmed it's account during
# this time frame, he/she will not able to sign in anymore.
Warden::Manager.after_set_user do |record, auth, options|
  if record && record.respond_to?(:active?) && !record.active?
    scope = options[:scope]
    auth.logout(scope)
    throw :warden, :scope => scope, :params => { :unconfirmed => true }
  end
end
