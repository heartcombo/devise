ActionController::Routing::Routes.draw do |map|
  Devise.mappings.each do |resource, mapping|
    map.namespace mapping.name, :namespace => nil, :path_prefix => mapping.as do |devise_map|
      devise_map.resource :session, :only => [:new, :create, :destroy]
      devise_map.resource :password, :only => [:new, :create, :edit, :update]
      devise_map.resource :confirmation, :only => [:new, :create, :show]
    end
  end
end
