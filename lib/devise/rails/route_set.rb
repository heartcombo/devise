require "active_support/core_ext/object/try"

module ActionDispatch::Routing
  module RouteSetFinalizeWithDevise
    def finalize!
      result = super

      @devise_finalized ||= begin
        if Devise.router_name.nil? && defined?(@devise_finalized) && self != Rails.application.try(:routes)
          warn "[DEVISE] We have detected that you are using devise_for inside engine routes. " \
            "In this case, you probably want to set Devise.router_name = MOUNT_POINT, where "   \
            "MOUNT_POINT is a symbol representing where this engine will be mounted at. For "   \
            "now Devise will default the mount point to :main_app. You can explicitly set it"   \
            " to :main_app as well in case you want to keep the current behavior."
        end

        Devise.configure_warden!
        Devise.regenerate_helpers!
        true
      end

      result
    end
  end
end

ActionDispatch::Routing::RouteSet.prepend(ActionDispatch::Routing::RouteSetFinalizeWithDevise)