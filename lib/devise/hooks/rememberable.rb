# After authenticate hook to verify if the user in the given scope asked to be
# remembered while he does not sign out. Generates a new remember token for
# that specific user and adds a cookie with this user info to sign in this user
# automatically without asking for credentials. Refer to rememberable strategy
# for more info.
Warden::Manager.prepend_after_authentication do |record, warden, options|
  scope = options[:scope]
  remember_me = warden.params[scope].try(:fetch, :remember_me, nil)

  if Devise::TRUE_VALUES.include?(remember_me) &&
     warden.authenticated?(scope) && record.respond_to?(:remember_me!)
    record.remember_me!

    warden.response.set_cookie "remember_#{scope}_token", {
      :value => record.class.serialize_into_cookie(record),
      :expires => record.remember_expires_at,
      :path => "/"
    }
  end
end

# Before logout hook to forget the user in the given scope, only if rememberable
# is activated for this scope. Also clear remember token to ensure the user
# won't be remembered again.
# Notice that we forget the user if the record is frozen. This usually means the
# user was just deleted.
Warden::Manager.before_logout do |record, warden, options|
  scope = options[:scope]
  if record.respond_to?(:forget_me!)
    record.forget_me! unless record.frozen?
    warden.response.delete_cookie "remember_#{scope}_token", :path => "/"
  end
end