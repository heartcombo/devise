ActionController::Routing::Routes.draw do |map|
  def t(route_name)
    I18n.t(route_name, :scope => [:devise, :routes], :default => route_name.to_s)
  end

#  map.resource :session, :only => [:new, :create, :destroy], :as => t(:session)
#  map.resource :password, :only => [:new, :create, :edit, :update], :as => t(:password)
#  map.resource :confirmation, :only => [:new, :create, :show], :as => t(:confirmation)

  Devise.mappings.each do |mapping, options|
    map.namespace mapping, :namespace => nil, :path_prefix => options[:as] do |devise_map|
      devise_map.resource :session, :only => [:new, :create, :destroy], :as => t(:session)
      devise_map.resource :password, :only => [:new, :create, :edit, :update], :as => t(:password)
      devise_map.resource :confirmation, :only => [:new, :create, :show], :as => t(:confirmation)
    end
  end
end
