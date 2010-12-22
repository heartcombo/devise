# Deny user access whenever his account is not active yet. All strategies that inherits from
# Devise::Strategies::Authenticatable and uses the validate already check if the user is active?
# before actively signing him in. However, we need this as hook to validate the user activity
# in each request and in case the user is using other strategies beside Devise ones.
Warden::Manager.after_set_user do |record, warden, options|
  if record && record.respond_to?(:active?) && !record.active?
    warden.logout(options[:scope])
    options.merge!(:message => record.inactive_message)
    throw :warden, options
  end
end