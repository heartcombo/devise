Warden::Manager.after_set_user :except => :fetch do |record, warden, options|
  scope = options[:scope]
  if record.respond_to?(:remember_me) && record.remember_me && warden.authenticated?(scope)
    Devise::Controllers::Rememberable::Proxy.new(warden).remember_me(record)
  end
end