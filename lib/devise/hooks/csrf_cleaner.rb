Warden::Manager.after_authentication do |record, warden, options|
  if Devise.clean_up_csrf_token_on_authentication
    warden.request.session.try(:delete, :_csrf_token)
    warden.session(options[:scope]).try(:delete, :_csrf_token)
  end
end
