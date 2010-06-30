Rails::Application.routes.draw do
  resources :users, :only => [:index] do
    get :expire, :on => :member
    get :accept, :on => :member
  end

  resources :admins, :only => [:index]

  devise_for :users
  devise_for :admin, :path => "admin_area", :controllers => { :sessions => "sessions" }, :skip => :passwords

  scope ":locale" do
    devise_for :accounts, :singular => "manager", :class_name => "User",
      :path_names => {
        :sign_in => "login", :sign_out => "logout",
        :password => "secret", :confirmation => "verification",
        :unlock => "unblock", :sign_up => "register",
        :registration => "management"
      }
  end

  match "/admin_area/home", :to => "admins#index", :as => :admin_root
  match "/sign_in", :to => "devise/sessions#new"

  # Dummy route for new admin pasword
  match "/anywhere", :to => "foo#bar", :as => :new_admin_password

  root :to => "home#index"

  authenticate(:admin) do
    match "/private", :to => "home#private", :as => :private
  end
end