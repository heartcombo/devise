module ActionController::Routing
  class RouteSet #:nodoc:

    # Ensure Devise modules are included only after loading routes, because we
    # need devise_for mappings already declared to create magic filters and
    # helpers.
    def load_routes_with_devise!
      load_routes_without_devise!
      return if Devise.mappings.empty?

      ActionController::Base.send :include, Devise::Controllers::Helpers
      ActionController::Base.send :include, Devise::Controllers::UrlHelpers

      ActionView::Base.send :include, Devise::Controllers::UrlHelpers
    end
    alias_method_chain :load_routes!, :devise

    class Mapper #:doc:
      # Includes devise_for method for routes. This method is responsible to
      # generate all needed routes for devise, based on what modules you have
      # defined in your model.
      # Examples: Let's say you have an User model configured to use
      # authenticatable, confirmable and recoverable modules. After creating this
      # inside your routes:
      #
      #   map.devise_for :users
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
      #  * :class_name => setup a different class to be looked up by devise, if it cannot be correctly find by the route name.
      #
      #    map.devise_for :users, :class_name => 'Account'
      #
      #  * :as => allows you to setup path name that will be used, as rails routes does. The following route configuration would setup your route as /accounts instead of /users:
      #
      #    map.devise_for :users, :as => 'accounts'
      #
      #  * :scope => setup the scope name. This is used as the instance variable name in controller, as the name in routes and the scope given to warden. Defaults to the singular of the given name:
      #
      #    map.devise_for :users, :scope => :account
      #
      #  * :path_names => configure different path names to overwrite defaults :sign_in, :sign_out, :password and :confirmation.
      #
      #    map.devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification' }
      #
      #  * :path_prefix => the path prefix to be used in all routes.
      #
      #    map.devise_for :users, :path_prefix => "/:locale"
      #
      #  * :sign_out_via => restirct the HTTP method(s) accepted for the :sign_out action (default: :get), possible values are :post, :get, :put, :delete and :any, e.g. if you wish to restrict this to accept only :delete requests you should do:
      #
      #    map.devise_for :users, :sign_out_via => :delete
      #
      #    You need to make sure that your sign_out controls trigger a request with a matching HTTP method.
      #
      #  * :controllers => the controller which should be used. All routes by default points to Devise controllers. However, if you want them to point to custom controller, you should do:
      #
      #    map.devise_for :users, :controllers => { :sessions => "users/sessions" }
      #
      #  Any other options will be passed to route definition. If you need conditions for your routes, just map:
      #
      #    map.devise_for :users, :conditions => { :subdomain => /.+/ }
      #
      #  If you are using a dynamic prefix, like :locale above, you need to configure default_url_options through Devise. You can do that in config/initializers/devise.rb or setting a Devise.default_url_options:
      #
      #    Devise.default_url_options do
      #      { :locale => I18n.locale }
      #    end
      #
      def devise_for(*resources)
        options = resources.extract_options!

        resources.map!(&:to_sym)
        resources.each do |resource|
          mapping = Devise::Mapping.new(resource, options.dup)
          Devise.default_scope ||= mapping.name
          Devise.mappings[mapping.name] = mapping

          route_options = mapping.route_options.merge(:path_prefix => mapping.raw_path, :name_prefix => "#{mapping.name}_")

          with_options(route_options) do |routes|
            mapping.for.each do |mod|
              send(mod, routes, mapping) if self.respond_to?(mod, true)
            end
          end
        end
      end

      protected
        def database_authenticatable(routes, mapping)
          routes.with_options(:controller => mapping.custom_controllers_names[:sessions], :name_prefix => nil) do |session|
            session.send(:"new_#{mapping.name}_session",     mapping.path_names[:sign_in],  :action => 'new',     :conditions => { :method => :get })
            session.send(:"#{mapping.name}_session",         mapping.path_names[:sign_in],  :action => 'create',  :conditions => { :method => :post })
            destroy_options = { :action => 'destroy' }
            destroy_options.merge! :conditions => { :method => mapping.sign_out_via } unless mapping.sign_out_via == :any
            session.send(:"destroy_#{mapping.name}_session", mapping.path_names[:sign_out], destroy_options)
          end
        end

        def confirmable(routes, mapping)
          routes.resource :confirmation, :only => [:new, :create, :show],
                          :as => mapping.path_names[:confirmation],
                          :controller => mapping.custom_controllers_names[:confirmations]
        end

        def lockable(routes, mapping)
          routes.resource :unlock, :only => [:new, :create, :show],
                          :as => mapping.path_names[:unlock],
                          :controller => mapping.custom_controllers_names[:unlocks]
        end

        def recoverable(routes, mapping)
          routes.resource :password, :only => [:new, :create, :edit, :update],
                          :as => mapping.path_names[:password],
                          :controller => mapping.custom_controllers_names[:passwords]
        end

        def registerable(routes, mapping)
          routes.resource :registration, :only => [:new, :create, :edit, :update, :destroy],
                          :as => mapping.raw_path[1..-1],
                          :path_prefix => nil, :path_names => { :new => mapping.path_names[:sign_up] },
                          :controller => mapping.custom_controllers_names[:registrations]
        end
    end
  end
end
