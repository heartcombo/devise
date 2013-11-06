Warden::Manager.after_authentication do |record, warden, options|
  if Devise.clean_up_csrf_token_on_authentication
    session = warden.request.session
    authenticated_scopes = session.to_hash.map { |(k,v)|
      v && k.to_s.match(/^warden\.user\.(.+?)\.key$/) { |m| m[1].to_sym }
    }
    already_authenticated = (authenticated_scopes - [options[:scope]]).any?
    session.try(:delete, :_csrf_token) unless already_authenticated
  end
end
