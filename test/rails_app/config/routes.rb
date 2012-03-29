ActionController::Routing::Routes.draw do |map|
  map.devise_for :users
  map.devise_for :admin, :as => 'admin_area'
  map.devise_for :accounts, :scope => 'manager', :path_prefix => ':locale',
    :class_name => "User", :requirements => { :extra => 'value' }, :path_names => {
      :sign_in => 'login', :sign_out => 'logout',
      :password => 'secret', :confirmation => 'verification',
      :unlock => 'unblock', :sign_up => 'register'
    }

  map.resources :users, :only => [:index], :member => { :expire => :get }
  map.resources :admins, :only => :index
  map.root :controller => :home

  map.devise_for :sign_out_via_deletes, :sign_out_via => :delete, :class_name => "User"
  map.devise_for :sign_out_via_posts, :sign_out_via => :post, :class_name => "User"
  map.devise_for :sign_out_via_anymethods, :sign_out_via => :any, :class_name => "User"

  map.connect '/admin_area/password/new', :controller => "passwords", :action => "new"
  map.admin_root '/admin_area/home', :controller => "admins", :action => "index"

  map.connect '/sign_in', :controller => "sessions", :action => "new"
  map.connect '/any_url_you_wish', :controller => 'home', :action => 'index'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
