module ActionController::Routing
  class RouteSet #:nodoc:

    # Alias to include Devise modules after only loading routes, because we need
    # devise_for mappings already done to create magic filters and helpers.
    #
    def load_routes_with_devise!
      load_routes_without_devise!

      ActionController::Base.send :include, Devise::Controllers::Filters
      ActionController::Base.send :include, Devise::Controllers::Helpers
      ActionController::Base.send :include, Devise::Controllers::UrlHelpers

      ActionView::Base.send :include, Devise::Controllers::UrlHelpers
    end
    alias_method_chain :load_routes!, :devise

    class Mapper #:doc:
      # Includes devise_for map for routes.
      #
      def devise_for(*resources)
        options = resources.extract_options!

        resources.map!(&:to_sym)
        options.assert_valid_keys(:class_name, :as, :path_names)

        resources.each do |resource|
          mapping = Devise::Mapping.new(resource, options)
          Devise.mappings[mapping.name] = mapping

          if mapping.authenticable?
            with_options(:controller => 'sessions', :path_prefix => mapping.as) do |session|
              session.send(:"new_#{mapping.name}_session",     mapping.path_names[:sign_in],  :action => 'new',     :conditions => { :method => :get })
              session.send(:"#{mapping.name}_session",         mapping.path_names[:sign_in],  :action => 'create',  :conditions => { :method => :post })
              session.send(:"destroy_#{mapping.name}_session", mapping.path_names[:sign_out], :action => 'destroy', :conditions => { :method => :get })
            end
          end

          namespace mapping.name, :namespace => nil, :path_prefix => mapping.as do |m|
            if mapping.recoverable?
              m.resource :password, :only => [:new, :create, :edit, :update], :as => mapping.path_names[:password]
            end

            if mapping.confirmable?
              m.resource :confirmation, :only => [:new, :create, :show], :as => mapping.path_names[:confirmation]
            end
          end
        end
      end
    end

  end
end
