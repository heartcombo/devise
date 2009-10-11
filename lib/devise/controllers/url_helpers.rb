module Devise
  module Controllers
    module UrlHelpers

      # TODO: refactor url helpers generation
      [:session, :password, :confirmation].each do |module_name|
        [:path, :url].each do |path_or_url|
          actions = ['', 'new_']
          actions << 'edit_' if module_name == :password
          actions.each do |action|
            class_eval <<-URL_HELPERS
              def #{action}#{module_name}_#{path_or_url}(*args)
                resource = case args.first
                  when ::ActiveRecord::Base, Symbol, String then args.shift
                end
                send("#{action}\#{resource_name(resource)}_#{module_name}_#{path_or_url}", *args)
              end
            URL_HELPERS
          end
        end
      end
    end
  end
end
