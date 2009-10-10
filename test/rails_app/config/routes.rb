ActionController::Routing::Routes.draw do |map|
  map.resources :users, :only => :index
  map.resources :admins, :only => :index
  map.root :controller => :home
end
