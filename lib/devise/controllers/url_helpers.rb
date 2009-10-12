module Devise
  module Controllers
    module UrlHelpers

    protected

      [:session, :password, :confirmation].each do |module_name|
        [:path, :url].each do |path_or_url|
          actions = [ nil, :new_ ]
          actions << :edit_ if module_name == :password

          actions.each do |action|
            class_eval <<-URL_HELPERS
              def #{action}#{module_name}_#{path_or_url}(resource, *args)
                resource = case resource
                  when Symbol, String
                    resource
                  when Class
                    resource.name.underscore
                  else
                    resource.class.name.underscore
                end

                send("#{action}\#{resource}_#{module_name}_#{path_or_url}", *args)
              end
            URL_HELPERS
          end
        end
      end

    end
  end
end
