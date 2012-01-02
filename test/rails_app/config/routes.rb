Rails.application.routes.draw do
  # Resources for testing
  resources :users, :only => [:index] do
    get :expire, :on => :member
    get :accept, :on => :member

    authenticate do
      post :exhibit, :on => :member
    end
  end

  resources :admins, :only => [:index]

  # Users scope
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" } do
    match "/devise_for/sign_in", :to => "devise/sessions#new"
  end

  as :user do
    match "/as/sign_in", :to => "devise/sessions#new"
  end

  match "/sign_in", :to => "devise/sessions#new"

  # Admin scope
  devise_for :admin, :path => "admin_area", :controllers => { :sessions => :"admins/sessions" }, :skip => :passwords

  match "/admin_area/home", :to => "admins#index", :as => :admin_root
  match "/anywhere", :to => "foo#bar", :as => :new_admin_password

  authenticate(:admin) do
    match "/private", :to => "home#private", :as => :private
  end

  authenticated :admin do
    match "/dashboard", :to => "home#admin_dashboard"
  end

  authenticated do
    match "/dashboard", :to => "home#user_dashboard"
  end

  unauthenticated do
    match "/join", :to => "home#join"
  end

  # Routes for constraints testing
  devise_for :headquarters_admin, :class_name => "Admin", :path => "headquarters", :constraints => {:host => /192\.168\.1\.\d\d\d/}

  constraints(:host => /192\.168\.1\.\d\d\d/) do
    devise_for :homebase_admin, :class_name => "Admin", :path => "homebase"
  end

  devise_for :skip_admin, :class_name => "Admin", :skip => :all

  # Routes for format=false testing
  devise_for :htmlonly_admin, :class_name => "Admin", :skip => [:confirmations, :unlocks], :path => "htmlonly_admin", :format => false, :skip_helpers => [:confirmations, :unlocks]
  devise_for :htmlonly_users, :class_name => "User", :only => [:confirmations, :unlocks], :path => "htmlonly_users", :format => false, :skip_helpers => true

  # Other routes for routing_test.rb
  devise_for :reader, :class_name => "User", :only => :passwords

  namespace :publisher, :path_names => { :sign_in => "i_dont_care", :sign_out => "get_out" } do
    devise_for :accounts, :class_name => "Admin", :path_names => { :sign_in => "get_in" }
  end

  scope ":locale", :module => :invalid do
    devise_for :accounts, :singular => "manager", :class_name => "Admin",
      :path_names => {
        :sign_in => "login", :sign_out => "logout",
        :password => "secret", :confirmation => "verification",
        :unlock => "unblock", :sign_up => "register",
        :registration => "management", :cancel => "giveup"
      }, :failure_app => lambda { |env| [404, {"Content-Type" => "text/plain"}, ["Oops, not found"]] }, :module => :devise
  end

  namespace :sign_out_via, :module => "devise" do
    devise_for :deletes, :sign_out_via => :delete, :class_name => "Admin"
    devise_for :posts, :sign_out_via => :post, :class_name => "Admin"
    devise_for :delete_or_posts, :sign_out_via => [:delete, :post], :class_name => "Admin"
  end

  match "/set", :to => "home#set"
  match "/unauthenticated", :to => "home#unauthenticated"

  root :to => "home#index"
end
