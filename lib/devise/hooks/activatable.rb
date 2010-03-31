# Deny user access whenever his account is not active yet.
Warden::Manager.after_set_user do |record, warden, options|
  if record && record.respond_to?(:active?) && !record.active?
    scope = options[:scope]
    warden.logout(scope)
    throw :warden, :scope => scope, :message => record.inactive_message
  end
end

module Devise
  module Hooks
    # Overwrite Devise base strategy to only authenticate an user if it's active.
    # If you have an strategy that does not use Devise::Strategy::Base, don't worry
    # because the hook above will still avoid it to authenticate.
    module Activatable
      def success!(resource)
        if resource.respond_to?(:active?) && !resource.active?
          fail!(resource.inactive_message)
        else
          super
        end
      end
    end
  end
end

Devise::Strategies::Base.send :include, Devise::Hooks::Activatable