module ActionController::Routing
  class RouteSet #:nodoc:

    def load_routes_with_devise!
      load_routes_without_devise!

      ActionController::Base.send :include, Devise::Controllers::Filters
      ActionController::Base.send :include, Devise::Controllers::Helpers
      ActionController::Base.send :include, Devise::Controllers::UrlHelpers

      ActionView::Base.send :include, Devise::Controllers::UrlHelpers
    end
    alias_method_chain :load_routes!, :devise

    class Mapper #:doc:
      def devise_for(*resources)
        options = resources.extract_options!

        resources.map!(&:to_sym)
        options.assert_valid_keys(:class_name, :as)

        resources.each do |resource|
          mapping = Devise::Mapping.new(resource, options)
          Devise.mappings[mapping.name] = mapping

          namespace mapping.name, :namespace => nil, :path_prefix => mapping.as do |m|
            if mapping.authenticable?
              m.resource :session, :only => [:new, :create, :destroy]
            end

            if mapping.recoverable?
              m.resource :password, :only => [:new, :create, :edit, :update]
            end

            if mapping.confirmable?
              m.resource :confirmation, :only => [:new, :create, :show]
            end
          end
        end
      end
    end

  end
end
