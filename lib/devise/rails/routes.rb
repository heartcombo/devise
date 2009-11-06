module ActionController::Routing
  class RouteSet #:nodoc:

    # Ensure Devise modules are included only after loading routes, because we
    # need devise_for mappings already declared to create magic filters and
    # helpers.
    def load_routes_with_devise!
      load_routes_without_devise!

      ActionController::Base.send :include, Devise::Controllers::Filters
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
      #  * :class_name => setup a different class to be looked up by devise, if it cannot be correctly find by the route name.
      #
      #    map.devise_for :users, :class_name => 'Account'
      #
      #  * :as => allows you to setup path name that will be used, as rails routes does. The following route configuration would setup your route as /accounts instead of /users:
      #
      #    map.devise_for :users, :as => 'accounts'
      #
      #  * :singular => setup the name used to create named routes. By default, for a :users key, it is going to be the singularized version, :user. To configure a named route like account_session_path instead of user_session_path just do:
      #
      #    map.devise_for :users, :singular => :account
      #
      #  * :path_names => configure different path names to overwrite defaults :sign_in, :sign_out, :password and :confirmation.
      #
      #    map.devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification' }
      #
      def devise_for(*resources)
        options = resources.extract_options!

        resources.map!(&:to_sym)
        options.assert_valid_keys(:class_name, :as, :path_names, :singular)

        resources.each do |resource|
          mapping = Devise::Mapping.new(resource, options)
          Devise.mappings[mapping.name] = mapping

          mapping.for.each do |strategy|
            send(strategy, mapping) if self.respond_to?(strategy, true)
          end
        end
      end

      protected

        def authenticatable(mapping)
          with_options(:controller => 'sessions', :path_prefix => mapping.as) do |session|
            session.send(:"new_#{mapping.name}_session",     mapping.path_names[:sign_in],  :action => 'new',     :conditions => { :method => :get })
            session.send(:"#{mapping.name}_session",         mapping.path_names[:sign_in],  :action => 'create',  :conditions => { :method => :post })
            session.send(:"destroy_#{mapping.name}_session", mapping.path_names[:sign_out], :action => 'destroy', :conditions => { :method => :get })
          end
        end

        def recoverable(mapping)
          resource :password, :only => [:new, :create, :edit, :update], :as => mapping.path_names[:password],
                              :path_prefix => mapping.as, :name_prefix => "#{mapping.name}_"
        end

        def confirmable(mapping)
          resource :confirmation, :only => [:new, :create, :show], :as => mapping.path_names[:confirmation],
                                  :path_prefix => mapping.as, :name_prefix => "#{mapping.name}_"
        end
    end

  end
end
