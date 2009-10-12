module Devise
  module Controllers
    module Filters

    protected

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
        class_eval <<-METHOD
          def #{mapping}_authenticate!
            warden.authenticate!(:devise, :scope => :#{mapping})
          end
        METHOD
      end

      # Helper for use in before_filters where no authentication is required.
      # Please note that all scopes will be tested within this filter, and if
      # one of then is authenticated the filter will redirect.
      #
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
