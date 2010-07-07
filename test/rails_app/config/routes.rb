Rails.application.routes.draw do
  # Resources for testing
  resources :users, :only => [:index] do
    get :expire, :on => :member
    get :accept, :on => :member
  end

  resources :admins, :only => [:index]

  # Users scope
  devise_for :users do
    match "/devise_for/sign_in", :to => "devise/sessions#new"
  end

  as :user do
    match "/as/sign_in", :to => "devise/sessions#new"
  end

  match "/sign_in", :to => "devise/sessions#new"

  # Admin scope
  devise_for :admin, :path => "admin_area", :controllers => { :sessions => "sessions" }, :skip => :passwords

  match "/admin_area/home", :to => "admins#index", :as => :admin_root
  match "/anywhere", :to => "foo#bar", :as => :new_admin_password

  authenticate(:admin) do
    match "/private", :to => "home#private", :as => :private
  end

  # Other routes for routing_test.rb
  namespace :publisher, :path_names => { :sign_in => "i_don_care", :sign_out => "get_out" } do
    devise_for :accounts, :class_name => "User", :path_names => { :sign_in => "get_in" }
  end

  scope ":locale" do
    devise_for :accounts, :singular => "manager", :class_name => "User",
      :path_names => {
        :sign_in => "login", :sign_out => "logout",
        :password => "secret", :confirmation => "verification",
        :unlock => "unblock", :sign_up => "register",
        :registration => "management"
      }
  end

  root :to => "home#index"
end