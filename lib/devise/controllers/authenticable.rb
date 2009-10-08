module Devise
  module Controllers
    module Authenticable

      def require_no_authentication
        redirect_to root_path if authenticated?
      end
    end
  end
end
