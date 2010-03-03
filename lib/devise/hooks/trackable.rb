# After each sign in, update sign in time, sign in count and sign in IP.
Warden::Manager.after_set_user :except => :fetch do |record, warden, options|
  scope = options[:scope]
  if record.respond_to?(:update_tracked_fields!) && warden.authenticated?(scope)
    record.update_tracked_fields!(warden.request)
  end
end
