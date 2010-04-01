# Before logout hook to forget the user in the given scope, if it responds
# to forget_me! Also clear remember token to ensure the user won't be
# remembered again. Notice that we forget the user unless the record is frozen.
# This avoids forgetting deleted users.
Warden::Manager.before_logout do |record, warden, scope|
  if record.respond_to?(:forget_me!)
    record.forget_me! unless record.frozen?
    warden.cookies.delete "remember_#{scope}_token"
  end
end

module Devise
  module Hooks
    # Overwrite success! in authentication strategies allowing users to be remembered.
    # We choose to implement this as an strategy hook instead of a Devise hook to avoid users
    # giving a remember_me access in strategies that should not create remember me tokens.
    module Rememberable #:nodoc:
      def success!(resource)
        super

        if succeeded? && resource.respond_to?(:remember_me!) && remember_me?
          resource.remember_me!

          cookies.signed["remember_#{scope}_token"] = {
            :value => resource.class.serialize_into_cookie(resource),
            :expires => resource.remember_expires_at,
            :path => "/"
          }
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