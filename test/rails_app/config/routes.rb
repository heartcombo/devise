ActionController::Routing::Routes.draw do |map|
  map.resources :home, :only => :index
  map.root :controller => :home
end
