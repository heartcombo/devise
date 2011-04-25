Rails.application.routes.draw do
  # Resources for testing
  resources :users, :only => [:index] do
    get :expire, :on => :member
    get :accept, :on => :member
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

  # Other routes for routing_test.rb
  devise_for :reader, :class_name => "User", :only => :passwords

  namespace :publisher, :path_names => { :sign_in => "i_dont_care", :sign_out => "get_out" } do
    devise_for :accounts, :class_name => "Admin", :path_names => { :sign_in => "get_in" }
  end

  scope ":locale" do
    devise_for :accounts, :singular => "manager", :class_name => "Admin",
      :path_names => {
        :sign_in => "login", :sign_out => "logout",
        :password => "secret", :confirmation => "verification",
        :unlock => "unblock", :sign_up => "register",
        :registration => "management", :cancel => "giveup"
      }
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