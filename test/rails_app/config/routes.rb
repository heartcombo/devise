Rails::Application.routes.draw do
  resources :users, :only => [:index] do
    get :expire, :on => :member
  end

  devise_for :users
  devise_for :admin, :as => 'admin_area'
  devise_for :accounts, :scope => 'manager', :path_prefix => ':locale',
    :class_name => "User", :path_names => {
      :sign_in => 'login', :sign_out => 'logout',
      :password => 'secret', :confirmation => 'verification',
      :unlock => 'unblock', :sign_up => 'register'
    }

  resources :admins, :only => [:index]
  root :to => "home#index"

  match '/admin_area/password/new', :to => "passwords#new"
  match '/admin_area/home', :to => "admins#index", :as => :admin_root

  match '/sign_in', :to => "sessions#new"
end
