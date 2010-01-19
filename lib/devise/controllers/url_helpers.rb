module Devise
  module Controllers
    # Create url helpers to be used with resource/scope configuration. Acts as
    # proxies to the generated routes created by devise.
    # Resource param can be a string or symbol, a class, or an instance object.
    # Example using a :user resource:
    #
    #   new_session_path(:user)      => new_user_session_path
    #   session_path(:user)          => user_session_path
    #   destroy_session_path(:user)  => destroy_user_session_path
    #
    #   new_password_path(:user)     => new_user_password_path
    #   password_path(:user)         => user_password_path
    #   edit_password_path(:user)    => edit_user_password_path
    #
    #   new_confirmation_path(:user) => new_user_confirmation_path
    #   confirmation_path(:user)     => user_confirmation_path
    #
    # Those helpers are added to your ApplicationController.
    module UrlHelpers

      [:session, :password, :confirmation, :unlock].each do |module_name|
        [:path, :url].each do |path_or_url|
          actions = [ nil, :new_ ]
          actions << :edit_    if module_name == :password
          actions << :destroy_ if module_name == :session

          actions.each do |action|
            class_eval <<-URL_HELPERS
              def #{action}#{module_name}_#{path_or_url}(resource, *args)
                resource = Devise::Mapping.find_scope!(resource)
                send("#{action}\#{resource}_#{module_name}_#{path_or_url}", *args)
              end
            URL_HELPERS
          end
        end
      end

    end
  end
end
