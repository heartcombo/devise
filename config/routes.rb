ActionController::Routing::Routes.draw do |map|
  def t(route_name)
    I18n.t(route_name, :scope => [:devise, :routes], :default => route_name.to_s)
  end

  Devise.mappings.each do |resource, mapping|
    map.namespace mapping.resource, :namespace => nil, :path_prefix => mapping.as do |devise_map|
      devise_map.resource :session, :only => [:new, :create, :destroy], :as => t(:session)
      devise_map.resource :password, :only => [:new, :create, :edit, :update], :as => t(:password)
      devise_map.resource :confirmation, :only => [:new, :create, :show], :as => t(:confirmation)
    end
  end
end
