ActionController::Routing::Routes.draw do |map|
  map.devise_for :users
  map.devise_for :admin, :as => 'admin_area'
  map.devise_for :accounts, :path_names => {
    :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification'
  }, :scope => 'manager', :path_prefix => '/:locale', :requirements => { :extra => 'value' }

  map.resources :users, :only => [:index], :member => { :expire => :get }
  map.resources :admins, :only => :index
  map.root :controller => :home

  map.connect '/admin_area/password/new', :controller => "passwords", :action => "new"
  map.admin_root '/admin_area/home', :controller => "admins", :action => "index"

  map.connect '/sign_in', :controller => "sessions", :action => "new"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
