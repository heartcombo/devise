# After each sign in, if resource responds to failed_attempts, sets it to 0
# This is only triggered when the user is explicitly set (with set_user)
Warden::Manager.after_set_user :except => :fetch do |record, warden, options|
  if record.respond_to?(:failed_attempts) && warden.authenticated?(options[:scope])
    record.update_attribute(:failed_attempts, 0) unless record.failed_attempts.zero?
  end
end
