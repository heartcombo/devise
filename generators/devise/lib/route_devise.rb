module Rails
  module Generator
    module Commands
      class Create < Base

        # Create devise route. Based on route_resources
        def route_devise(*resources)
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          sentinel = 'ActionController::Routing::Routes.draw do |map|'

          logger.route "map.devise_for #{resource_list}"
          unless options[:pretend]
            gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
              "#{match}\n  map.devise_for #{resource_list}\n"
            end
          end
        end
      end

      class Destroy < RewindBase

        # Destroy devise route. Based on route_resources
        def route_devise(*resources)
          resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
          look_for = "\n  map.devise_for #{resource_list}\n"
          logger.route "map.devise_for #{resource_list}"
          gsub_file 'config/routes.rb', /(#{look_for})/mi, ''
        end
      end
    end
  end
end
