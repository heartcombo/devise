module ActionDispatch::Routing
  class RouteSet #:nodoc:
    # Ensure Devise modules are included only after loading routes, because we
    # need devise_for mappings already declared to create filters and helpers.
    def finalize_with_devise!
      finalize_without_devise!
      Devise.configure_warden!
      ActionController::Base.send :include, Devise::Controllers::Helpers
    end
    alias_method_chain :finalize!, :devise
  end

  class Mapper
    # Includes devise_for method for routes. This method is responsible to
    # generate all needed routes for devise, based on what modules you have
    # defined in your model.
    #
    # ==== Examples
    #
    # Let's say you have an User model configured to use authenticatable,
    # confirmable and recoverable modules. After creating this inside your routes:
    #
    #   devise_for :users
    #
    # This method is going to look inside your User model and create the
    # needed routes:
    #
    #  # Session routes for Authenticatable (default)
    #       new_user_session GET  /users/sign_in                    {:controller=>"devise/sessions", :action=>"new"}
    #           user_session POST /users/sign_in                    {:controller=>"devise/sessions", :action=>"create"}
    #   destroy_user_session GET  /users/sign_out                   {:controller=>"devise/sessions", :action=>"destroy"}
    #
    #  # Password routes for Recoverable, if User model has :recoverable configured
    #      new_user_password GET  /users/password/new(.:format)     {:controller=>"devise/passwords", :action=>"new"}
    #     edit_user_password GET  /users/password/edit(.:format)    {:controller=>"devise/passwords", :action=>"edit"}
    #          user_password PUT  /users/password(.:format)         {:controller=>"devise/passwords", :action=>"update"}
    #                        POST /users/password(.:format)         {:controller=>"devise/passwords", :action=>"create"}
    #
    #  # Confirmation routes for Confirmable, if User model has :confirmable configured
    #  new_user_confirmation GET  /users/confirmation/new(.:format) {:controller=>"devise/confirmations", :action=>"new"}
    #      user_confirmation GET  /users/confirmation(.:format)     {:controller=>"devise/confirmations", :action=>"show"}
    #                        POST /users/confirmation(.:format)     {:controller=>"devise/confirmations", :action=>"create"}
    #
    # ==== Options
    #
    # You can configure your routes with some options:
    #
    #  * :class_name => setup a different class to be looked up by devise,
    #                   if it cannot be correctly find by the route name.
    #
    #      devise_for :users, :class_name => 'Account'
    #
    #  * :path => allows you to setup path name that will be used, as rails routes does.
    #             The following route configuration would setup your route as /accounts instead of /users:
    #
    #      devise_for :users, :path => 'accounts'
    #
    #  * :singular => setup the singular name for the given resource. This is used as the instance variable name in
    #                 controller, as the name in routes and the scope given to warden.
    #
    #      devise_for :users, :singular => :user
    #
    #  * :path_names => configure different path names to overwrite defaults :sign_in, :sign_out, :sign_up,
    #                   :password, :confirmation, :unlock.
    #
    #      devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification' }
    #
    #  * :controllers => the controller which should be used. All routes by default points to Devise controllers.
    #    However, if you want them to point to custom controller, you should do:
    #
    #      devise_for :users, :controllers => { :sessions => "users/sessions" }
    #
    #  * :skip => tell which controller you want to skip routes from being created:
    #
    #      devise_for :users, :skip => :sessions
    #
    # ==== Scoping
    #
    # Following Rails 3 routes DSL, you can nest devise_for calls inside a scope:
    #
    #   scope "/my" do
    #     devise_for :users
    #   end
    #
    # However, since Devise uses the request path to retrieve the current user, this has a few caveats.
    # First, if you are using a dynamic segment, as below:
    #
    #   scope ":locale" do
    #     devise_for :users
    #   end
    #
    # You are required to configure default_url_options in your ApplicationController class level, so
    # Devise can pick it:
    #
    #   class ApplicationController < ActionController::Base
    #     def self.default_url_options
    #       { :locale => I18n.locale }
    #     end
    #   end
    #
    # Second, since Devise expects routes in the format "user_session_path" to be defined, you cannot
    # scope to a given route name as below:
    #
    #   scope "/special_scope", :as => :special_scope do # THIS WILL FAIL
    #     devise_for :users
    #   end
    #
    # Finally, Devise does not (and cannot) support optional segments, either static or dynamic. That
    # said, the following does not work:
    #
    #   scope "(/:locale)" do # THIS WILL FAIL
    #     devise_for :users
    #   end
    #
    def devise_for(*resources)
      options = resources.extract_options!

      if options.key?(:path_prefix)
        ActiveSupport::Deprecation.warn "Giving :path_prefix to devise_for is deprecated and has no effect. " << 
          "Please use scope from the new router DSL instead."
      end

      options[:path_prefix] = @scope[:path]
      resources.map!(&:to_sym)

      resources.each do |resource|
        mapping = Devise.add_model(resource, options)

        begin
          raise_no_devise_method_error!(mapping.class_name) unless mapping.to.respond_to?(:devise)
        rescue NameError => e
          raise unless mapping.class_name == resource.to_s.classify
          warn "[WARNING] You provided devise_for #{resource.inspect} but there is " <<
            "no model #{mapping.class_name} defined in your application"
          next
        rescue NoMethodError => e
          raise unless e.message.include?("undefined method `devise'")
          raise_no_devise_method_error!(mapping.class_name)
        end

        routes  = mapping.routes
        routes -= Array(options.delete(:skip)).map { |s| s.to_s.singularize.to_sym }

        scope mapping.path.to_s, :as => mapping.name do
          routes.each { |mod| send(:"devise_#{mod}", mapping, mapping.controllers) }
        end
      end
    end

    # Allow you to add authentication request from the router:
    #
    #   authenticate(:user) do
    #     resources :post
    #   end
    #
    def authenticate(scope)
      constraint = lambda do |request|
        request.env["warden"].authenticate!(:scope => scope)
      end

      constraints(constraint) do
        yield
      end
    end

    protected

      def devise_session(mapping, controllers)
        scope :controller => controllers[:sessions], :as => :session do
          get  :new,     :path => mapping.path_names[:sign_in]
          post :create,  :path => mapping.path_names[:sign_in], :as => ""
          get  :destroy, :path => mapping.path_names[:sign_out]
        end
      end
 
      def devise_password(mapping, controllers)
        resource :password, :only => [:new, :create, :edit, :update],
          :path => mapping.path_names[:password], :controller => controllers[:passwords]
      end
 
      def devise_confirmation(mapping, controllers)
        resource :confirmation, :only => [:new, :create, :show],
          :path => mapping.path_names[:confirmation], :controller => controllers[:confirmations]
      end
 
      def devise_unlock(mapping, controllers)
        resource :unlock, :only => [:new, :create, :show],
          :path => mapping.path_names[:unlock], :controller => controllers[:unlocks]
      end

      def devise_registration(mapping, controllers)
        resource :registration, :only => [:new, :create, :edit, :update, :destroy], :path => mapping.path_names[:registration],
                 :path_names => { :new => mapping.path_names[:sign_up] }, :controller => controllers[:registrations]
      end

      def raise_no_devise_method_error!(klass)
        raise "#{klass} does not respond to 'devise' method. This usually means you haven't " <<
          "loaded your ORM file or it's being loaded too late. To fix it, be sure to require 'devise/orm/YOUR_ORM' " <<
          "inside 'config/initializers/devise.rb' or before your application definition in 'config/application.rb'"
      end
  end
end
