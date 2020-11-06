# frozen_string_literal: true

# After each sign in, if resource responds to failed_attempts, sets it to 0
# This is only triggered when the user is explicitly set (with set_user)
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  if record.respond_to?(:failed_attempts) && warden.authenticated?(options[:scope])
    unless record.failed_attempts.to_i.zero?
      wipe_attempts = Proc.new do
        record.failed_attempts = 0
        record.save(validate: false)
      end

      Devise.warden_hook_save_wrapper.call(wipe_attempts)
    end
  end
end
