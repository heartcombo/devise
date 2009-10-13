ActionController::Routing::Routes.draw do |map|
  map.devise_for :users
  map.devise_for :admin, :as => 'admin_area'

  map.resources :users, :only => :index
  map.resources :admins, :only => :index
  map.root :controller => :home

  map.connect '/admin_area/password/new', :controller => "passwords", :action => "new"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
