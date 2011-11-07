module ActionDispatch::Routing
  class RouteSet #:nodoc:
    # Ensure Devise modules are included only after loading routes, because we
    # need devise_for mappings already declared to create filters and helpers.
    def finalize_with_devise!
      finalize_without_devise!

      @devise_finalized ||= begin
        Devise.configure_warden!
        Devise.regenerate_helpers!
        true
      end
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
    #  * :class_name => setup a different class to be looked up by devise, if it cannot be
    #    properly found by the route name.
    #
    #      devise_for :users, :class_name => 'Account'
    #
    #  * :path => allows you to setup path name that will be used, as rails routes does.
    #    The following route configuration would setup your route as /accounts instead of /users:
    #
    #      devise_for :users, :path => 'accounts'
    #
    #  * :singular => setup the singular name for the given resource. This is used as the instance variable
    #    name in controller, as the name in routes and the scope given to warden.
    #
    #      devise_for :users, :singular => :user
    #
    #  * :path_names => configure different path names to overwrite defaults :sign_in, :sign_out, :sign_up,
    #    :password, :confirmation, :unlock.
    #
    #      devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification' }
    #
    #  * :controllers => the controller which should be used. All routes by default points to Devise controllers.
    #    However, if you want them to point to custom controller, you should do:
    #
    #      devise_for :users, :controllers => { :sessions => "users/sessions" }
    #
    #  * :failure_app => a rack app which is invoked whenever there is a failure. Strings representing a given
    #    are also allowed as parameter.
    #
    #  * :sign_out_via => the HTTP method(s) accepted for the :sign_out action (default: :get),
    #    if you wish to restrict this to accept only :post or :delete requests you should do:
    #
    #      devise_for :users, :sign_out_via => [ :post, :delete ]
    #
    #    You need to make sure that your sign_out controls trigger a request with a matching HTTP method.
    #
    #  * :module => the namespace to find controlers. By default, devise will access devise/sessions,
    #    devise/registrations and so on. If you want to namespace all at once, use module:
    #
    #      devise_for :users, :module => "users"
    #
    #    Notice that whenever you use namespace in the router DSL, it automatically sets the module.
    #    So the following setup:
    #
    #      namespace :publisher
    #        devise_for :account
    #      end
    #
    #    Will use publisher/sessions controller instead of devise/sessions controller. You can revert
    #    this by providing the :module option to devise_for.
    #
    #    Also pay attention that when you use a namespace it will affect all the helpers and methods for controllers
    #    and views. For example, using the above setup you'll end with following methods:
    #    current_publisher_account, authenticate_publisher_account!, publisher_account_signed_in, etc.
    #
    #  * :skip => tell which controller you want to skip routes from being created:
    #
    #      devise_for :users, :skip => :sessions
    #
    #  * :only => the opposite of :skip, tell which controllers only to generate routes to:
    #
    #      devise_for :users, :only => :sessions
    #
    #  * :skip_helpers => skip generating Devise url helpers like new_session_path(@user).
    #    This is useful to avoid conflicts with previous routes and is false by default.
    #    It accepts true as option, meaning it will skip all the helpers for the controllers
    #    given in :skip but it also accepts specific helpers to be skipped:
    #
    #      devise_for :users, :skip => [:registrations, :confirmations], :skip_helpers => true
    #      devise_for :users, :skip_helpers => [:registrations, :confirmations]
    #
    #  * :format => include "(.:format)" in the generated routes? true by default, set to false to disable:
    #
    #      devise_for :users, :format => false
    #
    #  * :constraints => works the same as Rails' contraints
    #
    #  * :defaults => works the same as Rails' defaults
    #
    # ==== Scoping
    #
    # Following Rails 3 routes DSL, you can nest devise_for calls inside a scope:
    #
    #   scope "/my" do
    #     devise_for :users
    #   end
    #
    # However, since Devise uses the request path to retrieve the current user, it has one caveats.
    # If you are using a dynamic segment, as below:
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
    # ==== Adding custom actions to override controllers
    #
    # You can pass a block to devise_for that will add any routes defined in the block to Devise's
    # list of known actions.  This is important if you add a custom action to a controller that
    # overrides an out of the box Devise controller.
    # For example:
    #
    #    class RegistrationsController < Devise::RegistrationsController
    #      def update
    #         # do something different here
    #      end
    #
    #      def deactivate
    #        # not a standard action
    #        # deactivate code here
    #      end
    #    end
    #
    # In order to get Devise to recognize the deactivate action, your devise_for entry should look like this,
    #
    #     devise_for :owners, :controllers => { :registrations => "registrations" } do
    #       post "deactivate", :to => "registrations#deactivate", :as => "deactivate_registration"
    #     end
    #
    def devise_for(*resources)
      @devise_finalized = false
      options = resources.extract_options!

      options[:as]          ||= @scope[:as]     if @scope[:as].present?
      options[:module]      ||= @scope[:module] if @scope[:module].present?
      options[:path_prefix] ||= @scope[:path]   if @scope[:path].present?
      options[:path_names]    = (@scope[:path_names] || {}).merge(options[:path_names] || {})
      options[:constraints]   = (@scope[:constraints] || {}).merge(options[:constraints] || {})
      options[:defaults]      = (@scope[:defaults] || {}).merge(options[:defaults] || {})
      @scope[:options]        = (@scope[:options] || {}).merge({:format => false}) if options[:format] == false

      resources.map!(&:to_sym)

      resources.each do |resource|
        mapping = Devise.add_mapping(resource, options)

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

        routes  = mapping.used_routes

        devise_scope mapping.name do
          yield if block_given?
          with_devise_exclusive_scope mapping.fullpath, mapping.name, mapping.constraints, mapping.defaults do
            routes.each { |mod| send("devise_#{mod}", mapping, mapping.controllers) }
          end
        end
      end
    end

    # Allow you to add authentication request from the router:
    #
    #   authenticate do
    #     resources :post
    #   end
    #
    #   authenticate(:admin) do
    #     resources :users
    #   end
    #
    def authenticate(scope=nil)
      constraint = lambda do |request|
        request.env["warden"].authenticate!(:scope => scope)
      end

      constraints(constraint) do
        yield
      end
    end

    # Allow you to route based on whether a scope is authenticated. You
    # can optionally specify which scope.
    #
    #   authenticated :admin do
    #     root :to => 'admin/dashboard#show'
    #   end
    #
    #   authenticated do
    #     root :to => 'dashboard#show'
    #   end
    #
    #   root :to => 'landing#show'
    #
    def authenticated(scope=nil)
      constraint = lambda do |request|
        request.env["warden"].authenticate? :scope => scope
      end

      constraints(constraint) do
        yield
      end
    end

    # Allow you to route based on whether a scope is *not* authenticated.
    # You can optionally specify which scope.
    #
    #   unauthenticated do
    #     as :user do
    #       root :to => 'devise/registrations#new'
    #     end
    #   end
    #
    #   root :to => 'dashboard#show'
    #
    def unauthenticated(scope=nil)
      constraint = lambda do |request|
        not request.env["warden"].authenticate? :scope => scope
      end

      constraints(constraint) do
        yield
      end
    end

    # Sets the devise scope to be used in the controller. If you have custom routes,
    # you are required to call this method (also aliased as :as) in order to specify
    # to which controller it is targetted.
    #
    #   as :user do
    #     get "sign_in", :to => "devise/sessions#new"
    #   end
    #
    # Notice you cannot have two scopes mapping to the same URL. And remember, if
    # you try to access a devise controller without specifying a scope, it will
    # raise ActionNotFound error.
    #
    # Also be aware of that 'devise_scope' and 'as' use the singular form of the
    # noun where other devise route commands expect the plural form. This would be a
    # good and working example.
    #
    #  devise_scope :user do
    #    match "/some/route" => "some_devise_controller"
    #  end
    #  devise_for :users
    #
    # Notice and be aware of the differences above between :user and :users
    def devise_scope(scope)
      constraint = lambda do |request|
        request.env["devise.mapping"] = Devise.mappings[scope]
        true
      end

      constraints(constraint) do
        yield
      end
    end
    alias :as :devise_scope

    protected

      def devise_session(mapping, controllers) #:nodoc:
        resource :session, :only => [], :controller => controllers[:sessions], :path => "" do
          get   :new,     :path => mapping.path_names[:sign_in],  :as => "new"
          post  :create,  :path => mapping.path_names[:sign_in]
          match :destroy, :path => mapping.path_names[:sign_out], :as => "destroy", :via => mapping.sign_out_via
        end
      end

      def devise_password(mapping, controllers) #:nodoc:
        resource :password, :only => [:new, :create, :edit, :update],
          :path => mapping.path_names[:password], :controller => controllers[:passwords]
      end

      def devise_confirmation(mapping, controllers) #:nodoc:
        resource :confirmation, :only => [:new, :create, :show],
          :path => mapping.path_names[:confirmation], :controller => controllers[:confirmations]
      end

      def devise_unlock(mapping, controllers) #:nodoc:
        if mapping.to.unlock_strategy_enabled?(:email)
          resource :unlock, :only => [:new, :create, :show],
            :path => mapping.path_names[:unlock], :controller => controllers[:unlocks]
        end
      end

      def devise_registration(mapping, controllers) #:nodoc:
        path_names = {
          :new => mapping.path_names[:sign_up],
          :cancel => mapping.path_names[:cancel]
        }

        resource :registration, :only => [:new, :create, :edit, :update, :destroy], :path => mapping.path_names[:registration],
                 :path_names => path_names, :controller => controllers[:registrations] do
          get :cancel
        end
      end

      def devise_omniauth_callback(mapping, controllers) #:nodoc:
        path, @scope[:path] = @scope[:path], nil
        path_prefix = "/#{mapping.path}/auth".squeeze("/")

        if ::OmniAuth.config.path_prefix && ::OmniAuth.config.path_prefix != path_prefix
          raise "You can only add :omniauthable behavior to one Devise model"
        else
          ::OmniAuth.config.path_prefix = path_prefix
        end

        match "#{path_prefix}/:action/callback", :constraints => { :action => Regexp.union(mapping.to.omniauth_providers.map(&:to_s)) },
          :to => controllers[:omniauth_callbacks], :as => :omniauth_callback
      ensure
        @scope[:path] = path
      end

      def with_devise_exclusive_scope(new_path, new_as, new_constraints, new_defaults) #:nodoc:
        old_as, old_path, old_module, old_constraints, old_defaults = @scope[:as], @scope[:path], @scope[:module], @scope[:constraints], @scope[:defaults]
        @scope[:as], @scope[:path], @scope[:module], @scope[:constraints], @scope[:defaults] = new_as, new_path, nil, new_constraints, new_defaults
        yield
      ensure
        @scope[:as], @scope[:path], @scope[:module], @scope[:constraints], @scope[:defaults] = old_as, old_path, old_module, old_constraints, old_defaults
      end

      def raise_no_devise_method_error!(klass) #:nodoc:
        raise "#{klass} does not respond to 'devise' method. This usually means you haven't " \
          "loaded your ORM file or it's being loaded too late. To fix it, be sure to require 'devise/orm/YOUR_ORM' " \
          "inside 'config/initializers/devise.rb' or before your application definition in 'config/application.rb'"
      end
  end
end
