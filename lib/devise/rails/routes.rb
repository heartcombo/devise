module ActionDispatch::Routing
  class RouteSet #:nodoc:
    # Ensure Devise modules are included only after loading routes, because we
    # need devise_for mappings already declared to create filters and helpers.
    def finalize_with_devise!
      finalize_without_devise!
      return if Devise.mappings.empty?

      ActionController::Base.send :include, Devise::Controllers::Helpers
      ActionController::Base.send :include, Devise::Controllers::UrlHelpers

      ActionView::Base.send :include, Devise::Controllers::UrlHelpers
    end
    alias_method_chain :finalize!, :devise
  end

  class Mapper
    # Includes devise_for method for routes. This method is responsible to
    # generate all needed routes for devise, based on what modules you have
    # defined in your model.
    # Examples: Let's say you have an User model configured to use
    # authenticatable, confirmable and recoverable modules. After creating this
    # inside your routes:
    #
    #   devise_for :users
    #
    # this method is going to look inside your User model and create the
    # needed routes:
    #
    #  # Session routes for Authenticatable (default)
    #       new_user_session GET  /users/sign_in                    {:controller=>"sessions", :action=>"new"}
    #           user_session POST /users/sign_in                    {:controller=>"sessions", :action=>"create"}
    #   destroy_user_session GET  /users/sign_out                   {:controller=>"sessions", :action=>"destroy"}
    #
    #  # Password routes for Recoverable, if User model has :recoverable configured
    #      new_user_password GET  /users/password/new(.:format)     {:controller=>"passwords", :action=>"new"}
    #     edit_user_password GET  /users/password/edit(.:format)    {:controller=>"passwords", :action=>"edit"}
    #          user_password PUT  /users/password(.:format)         {:controller=>"passwords", :action=>"update"}
    #                        POST /users/password(.:format)         {:controller=>"passwords", :action=>"create"}
    #
    #  # Confirmation routes for Confirmable, if User model has :confirmable configured
    #  new_user_confirmation GET  /users/confirmation/new(.:format) {:controller=>"confirmations", :action=>"new"}
    #      user_confirmation GET  /users/confirmation(.:format)     {:controller=>"confirmations", :action=>"show"}
    #                        POST /users/confirmation(.:format)     {:controller=>"confirmations", :action=>"create"}
    #
    # You can configure your routes with some options:
    #
    #  * :class_name => setup a different class to be looked up by devise,
    #                   if it cannot be correctly find by the route name.
    #
    #    devise_for :users, :class_name => 'Account'
    #
    #  * :as => allows you to setup path name that will be used, as rails routes does.
    #           The following route configuration would setup your route as /accounts instead of /users:
    #
    #    devise_for :users, :as => 'accounts'
    #
    #  * :scope => setup the scope name. This is used as the instance variable name in controller,
    #              as the name in routes and the scope given to warden. Defaults to the singular of the given name:
    #
    #    devise_for :users, :scope => :account
    #
    #  * :path_names => configure different path names to overwrite defaults :sign_in, :sign_out, :sign_up,
    #                   :password, :confirmation, :unlock.
    #
    #    devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification' }
    #
    #  * :path_prefix => the path prefix to be used in all routes.
    #
    #    devise_for :users, :path_prefix => "/:locale"
    #
    #  If you are using a dynamic prefix, like :locale above, you need to configure default_url_options in your ApplicationController
    #  class level, so Devise can pick it:
    #
    #    class ApplicationController < ActionController::Base
    #      def self.default_url_options
    #        { :locale => I18n.locale }
    #      end
    #    end
    #
    #  * :controllers => the controller which should be used. All routes by default points to Devise controllers.
    #    However, if you want them to point to custom controller, you should do:
    #
    #    devise_for :users, :controllers => { :sessions => "users/sessions" }
    #
    #  * :skip => tell which controller you want to skip routes from being created:
    #
    #    devise_for :users, :skip => :sessions
    #
    def devise_for(*resources)
      options = resources.extract_options!
      resources.map!(&:to_sym)

      resources.each do |resource|
        mapping = Devise.register(resource, options)

        unless mapping.to.respond_to?(:devise)
          raise "#{mapping.to.name} does not respond to 'devise' method. This usually means you haven't " <<
            "loaded your ORM file or it's being loaded too late. To fix it, be sure to require 'devise/orm/YOUR_ORM' " <<
            "inside 'config/initializers/devise.rb' or before your application definition in 'config/application.rb'"
        end

        routes  = mapping.routes
        routes -= Array(options.delete(:skip)).map { |s| s.to_s.singularize.to_sym }

        routes.each do |mod|
          send(:"devise_#{mod}", mapping, mapping.controllers)
        end
      end
    end

    protected

      def devise_session(mapping, controllers)
        scope mapping.path do
          get  mapping.path_names[:sign_in],  :to => "#{controllers[:sessions]}#new",     :as => :"new_#{mapping.name}_session"
          post mapping.path_names[:sign_in],  :to => "#{controllers[:sessions]}#create",  :as => :"#{mapping.name}_session"
          get  mapping.path_names[:sign_out], :to => "#{controllers[:sessions]}#destroy", :as => :"destroy_#{mapping.name}_session"
        end
      end
 
      def devise_password(mapping, controllers)
        scope mapping.path, :name_prefix => mapping.name do
          resource :password, :only => [:new, :create, :edit, :update], :as => mapping.path_names[:password], :controller => controllers[:passwords]
        end
      end
 
      def devise_confirmation(mapping, controllers)
        scope mapping.path, :name_prefix => mapping.name do
          resource :confirmation, :only => [:new, :create, :show], :as => mapping.path_names[:confirmation], :controller => controllers[:confirmations]
        end
      end
 
      def devise_unlock(mapping, controllers)
        scope mapping.path, :name_prefix => mapping.name do
          resource :unlock, :only => [:new, :create, :show], :as => mapping.path_names[:unlock], :controller => controllers[:unlocks]
        end
      end

      def devise_registration(mapping, controllers)
        scope mapping.path[1..-1], :name_prefix => "#{mapping.name}_registration" do
          resource :registration, :only => [:new, :create, :edit, :update, :destroy], :as => "",
                   :path_names => { :new => mapping.path_names[:sign_up] }, :controller => controllers[:registrations]
        end
      end
  end
end