module Devise
  module Controllers
    module Authenticable

      # Helper for use in before_filters where no authentication is required:
      # Example:
      #   before_filter :require_no_authentication, :only => :new
      #
      def require_no_authentication
        redirect_to root_path if authenticated?
      end
    end
  end
end
