# After authenticate hook to verify if the user in the given scope asked to be
# remembered while he does not sign out. Generates a new remember token for
# that specific user and adds a cookie with this user info to sign in this user
# automatically without asking for credentials. Refer to rememberable strategy
# for more info.
Warden::Manager.after_authentication do |record, warden, options|
  scope = options[:scope]
  remember_me = warden.params[scope].try(:fetch, :remember_me, nil)

  if Devise::TRUE_VALUES.include?(remember_me) && record.respond_to?(:remember_me!)
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
Warden::Manager.before_logout do |record, warden, scope|
  if record.respond_to?(:forget_me!)
    record.forget_me!
    warden.response.delete_cookie "remember_#{scope}_token"
  end
end
