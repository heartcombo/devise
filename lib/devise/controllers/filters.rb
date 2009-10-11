module Devise
  module Controllers
    module Filters

      # Define authentication filters based on mappings. These filters should be
      # used inside the controllers as before_filters, so you can control the
      # scope of the user who should be signed in to access that specific
      # controller/action.
      #
      # Example:
      #   Maps:
      #     Devise.map :users, :for => [:authenticable]
      #     Devise.map :admin, :for => [:authenticable]
      #   Generated Filters:
      #     user_authenticate!
      #     admin_authenticate!
      #   Use:
      #     before_filter :user_authenticate! # Tell devise to use :user map
      #     before_filter :admin_authenticate! # Tell devise to use :admin map
      #
      Devise.mappings.each_key do |mapping|
        define_method(:"#{mapping}_authenticate!") do
          authenticate!(mapping)
        end
      end

      # Verify authenticated user and redirect to sign in if no authentication
      # is found
      #
      def authenticate!(scope)
        redirect_to new_session_path(scope) unless authenticated?(scope)
      end

      # Helper for use in before_filters where no authentication is required:
      # Example:
      #   before_filter :require_no_authentication, :only => :new
      #
      def require_no_authentication
        Devise.mappings.each_key do |map|
          redirect_to root_path if authenticated?(map)
        end
      end
    end
  end
end
