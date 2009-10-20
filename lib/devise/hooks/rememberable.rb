# After authenticate hook to verify if the user in the given scope asked to be
# remembered while he does not sign out. Generates a new remember token for
# that specific user and adds a cookie with this user info to sign in this user
# automatically without asking for credentials. Refer to rememberable strategy
# for more info.
Warden::Manager.after_authentication do |record, auth, options|
  scope = options[:scope]
  remember_me = auth.params[scope].try(:fetch, :remember_me, nil)
  remember_me = remember_me == '1' || remember_me == 'true'
  mapping = Devise.mappings[scope]
  if remember_me && mapping.present? && mapping.rememberable?
    record.remember_me!
    auth.cookies['remember_token'] = record.class.serialize_into_cookie(record)
  end
end

# Before logout hook to forget the user in the given scope, only if rememberable
# is activated for this scope. Also clear remember token to ensure the user
# won't be remembered again.
# TODO: verify warden to call before_logout when @users are not loaded yet.
Warden::Manager.before_logout do |record, auth, scope|
  mapping = Devise.mappings[scope]
  if mapping.present? && mapping.rememberable?
    record.forget_me!
    auth.cookies['remember_token'] = nil
  end
end
