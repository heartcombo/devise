# Deny user access whenever their account is not active yet. All strategies that inherits from
# Devise::Strategies::Authenticatable and uses the validate already check if the user is active_for_authentication?
# before actively signing them in. However, we need this as hook to validate the user activity
# in each request and in case the user is using other strategies beside Devise ones.
Warden::Manager.after_set_user do |record, warden, options|
  if record && record.respond_to?(:active_for_authentication?) && !record.active_for_authentication?
    scope = options[:scope]
    warden.logout(scope)
    throw :warden, scope: scope, message: record.inactive_message
  end
end
