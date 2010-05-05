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
          resource.remember_me!

          conf = {
            :value => resource.class.serialize_into_cookie(resource),
            :expires => resource.remember_expires_at,
            :path => "/"
          }

          conf[:domain] = resource.cookie_domain if resource.cookie_domain?  

          Warden::Manager.after_set_user do |record, warden, options|
            warden.cookies["remember_#{options[:scope]}_token"] = conf
          end
        end
      end

    protected

      def remember_me?
        valid_params? && Devise::TRUE_VALUES.include?(params_auth_hash[:remember_me])
      end
    end
  end
end

Devise::Strategies::Authenticatable.send :include, Devise::Hooks::Rememberable

