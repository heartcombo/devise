ActionController::Routing::Routes.draw do |map|
  map.resources :users, :only => :index
  map.resources :admins, :only => :index
  map.root :controller => :home

  map.connect '/users/password/new', :controller => "passwords", :action => "new"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
