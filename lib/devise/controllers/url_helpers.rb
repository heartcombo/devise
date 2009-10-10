module Devise
  module Controllers
    module UrlHelpers

      def resource_name(resource=nil)
        @resource_name ||= Devise.find_mapping(resource ? resource.class.name : request.path.split('/').second)
      end

      def resource_class
        @resource_class ||= resource_name.singularize.camelize.constantize
      end

      # TODO: refactor url helpers generation
      [:session, :password, :confirmation].each do |module_name|
        [:path, :url].each do |path_or_url|
          actions = ['', 'new_']
          actions << 'edit_' if module_name == :password
          actions.each do |action|
            class_eval <<-URL_HELPERS
              def #{action}#{module_name}_#{path_or_url}(*args)
                resource = args.first.is_a?(::ActiveRecord::Base) ? args.shift : nil
                send("#{action}\#{resource_name(resource)}_#{module_name}_#{path_or_url}", *args)
              end
            URL_HELPERS
          end
        end
      end

#        def new_session_path(*args)
#          send("new_#{resource_name}_session_path", *args)
#        end

#        def new_session_url(*args)
#          send("new_#{resource_name}_session_url", *args)
#        end

#        def session_path(*args)
#          send("#{resource_name}_session_path", *args)
#        end

#        def session_url(*args)
#          send("#{resource_name}_session_url", *args)
#        end

#        def new_confirmation_path(*args)
#          send("new_#{resource_name}_confirmation_path", *args)
#        end

#        def new_confirmation_url(*args)
#          send("new_#{resource_name}_confirmation_url", *args)
#        end

#        def confirmation_path(*args)
#          send("#{resource_name}_confirmation_path", *args)
#        end

#        def confirmation_url(*args)
#          send("#{resource_name}_confirmation_url", *args)
#        end

#        def new_password_path(*args)
#          send("new_#{resource_name}_password_path", *args)
#        end

#        def new_password_url(*args)
#          send("new_#{resource_name}_password_url", *args)
#        end

#        def password_path(*args)
#          send("#{resource_name}_password_path", *args)
#        end

#        def password_url(*args)
#          send("#{resource_name}_password_url", *args)
#        end

#        def edit_password_path(*args)
#          send("edit_#{resource_name}_password_path", *args)
#        end

#        def edit_password_url(*args)
#          send("edit_#{resource_name}_password_url", *args)
#        end
    end
  end
end
