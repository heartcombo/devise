module Devise
  module Controllers
    module Authenticable

      def self.included(base)
        base.class_eval do

#          helper_method :session_path, :session_url,
#                        :new_session_path, :new_session_url,
#                        :password_path, :password_url,
#                        :new_password_path, :new_password_url,
#                        :confirmation_path, :confirmation_url,
#                        :new_confirmation_path, :new_confirmation_url
        end
      end

      protected

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
