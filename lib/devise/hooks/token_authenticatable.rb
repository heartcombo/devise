# After each Warden-sign-in: Ensure authentication token is set - if this is enabled.
Warden::Manager.after_authentication do |record, warden, options|
  scope = options[:scope]
  puts "#"
  if Devise.mappings[scope].try(:token_authenticatable?) && warden.authenticated?(scope)
    Devise.reset_authentication_token_on ||= []

    if Devise.reset_authentication_token_on.include?(:after_set_user)
      record.reset_authentication_token!
    end
  end
end

# After each Authenticatable-password-change: Ensure authentication token is re-set - if this is enabled.
Devise.after_changed_password do |record, scope|
  if Devise.mappings[scope].try(:token_authenticatable?)
    Devise.reset_authentication_token_on ||= []

    if Devise.reset_authentication_token_on.include?(:after_changed_password)
      record.reset_authentication_token!
    end
  end
end if Devise.respond_to?(:after_changed_password)