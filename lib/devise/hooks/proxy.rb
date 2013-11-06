module Devise
  module Hooks
    # A small warden proxy so we can remember, forget and
    # sign out users from hooks.
    class Proxy #:nodoc:
      include Devise::Controllers::Rememberable
      include Devise::Controllers::SignInOut

      delegate :cookies, :env, :session, :to => :@warden

      def initialize(warden)
        @warden = warden
      end
    end
  end
end