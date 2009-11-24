# After each sign in, update sign in time, sign in count and sign in IP.
Warden::Manager.after_authentication do |record, warden, options|
  scope = options[:scope]
  if Devise.mappings[scope].try(:trackable?) && warden.authenticated?(scope)
    old_current, new_current  = record.current_sign_in_at, Time.now
    record.last_sign_in_at    = old_current || new_current
    record.current_sign_in_at = new_current

    old_current, new_current  = record.current_sign_in_ip, warden.request.remote_ip
    record.last_sign_in_ip    = old_current || new_current
    record.current_sign_in_ip = new_current

    record.sign_in_count ||= 0
    record.sign_in_count += 1

    record.save(false)
  end
end
