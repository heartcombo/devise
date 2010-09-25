module Devise
  module Hooks
    # Overwrite success! in authentication strategies allowing users to be remembered.
    # We choose to implement this as an strategy hook instead of a warden hook to allow a specific
    # strategy (like token authenticatable or facebook authenticatable) to turn off remember_me?
    # cookies.
    module Rememberable #:nodoc:
      def success!(resource)
        super

        if succeeded? && resource.respond_to?(:remember_me!) && remember_me?
          resource.remember_me!(extend_remember_period?)
          cookies.signed["remember_#{scope}_token"] = cookie_values(resource)
        end
      end

    protected

      def cookie_values(resource)
        options = Rails.configuration.session_options.slice(:path, :domain, :secure)
        options.merge!(resource.cookie_options)
        options.merge!(
          :value => resource.class.serialize_into_cookie(resource),
          :expires => resource.remember_expires_at
        )
        options
      end

      def succeeded?
        @result == :success
      end

      def extend_remember_period?
        false
      end

      def remember_me?
        valid_params? && Devise::TRUE_VALUES.include?(params_auth_hash[:remember_me])
      end
    end
  end
end

Devise::Strategies::Authenticatable.send :include, Devise::Hooks::Rememberable

