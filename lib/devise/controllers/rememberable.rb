module Devise
  module Controllers
    # A module that may be optionally included in a controller in order
    # to provide remember me behavior.
    module Rememberable
      # Return default cookie values retrieved from session options.
      def self.cookie_values
        Rails.configuration.session_options.slice(:path, :domain, :secure)
      end

      # A small warden proxy so we can remember and forget uses from hooks.
      class Proxy #:nodoc:
        include Devise::Controllers::Rememberable

        delegate :cookies, :env, :to => :@warden

        def initialize(warden)
          @warden = warden
        end
      end

      # Remembers the given resource by setting up a cookie
      def remember_me(resource, options = {})
        scope = options[:scope] || Devise::Mapping.find_scope!(resource)
        resource.remember_me!(resource.extend_remember_period)
        cookies.signed["remember_#{scope}_token"] = remember_cookie_values(resource)
      end

      # Forgets the given resource by deleting a cookie
      def forget_me(resource)
        scope = Devise::Mapping.find_scope!(resource)
        resource.forget_me!
        cookies.delete("remember_#{scope}_token", forget_cookie_values(resource))
      end

      protected

      def forget_cookie_values(resource)
        Devise::Controllers::Rememberable.cookie_values.merge!(resource.cookie_options)
      end

      def remember_cookie_values(resource)
        options = { :httponly => true }
        options.merge!(forget_cookie_values(resource))
        options.merge!(
          :value => resource.class.serialize_into_cookie(resource),
          :expires => resource.remember_expires_at
        )
      end
    end
  end
end