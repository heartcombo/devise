module Devise
  module Orm
    module DataMapper
      module Hook
        def devise_modules_hook!
          extend Schema
          include Compatibility
          yield
          return unless Devise.apply_schema
          devise_modules.each { |m| send(m) if respond_to?(m, true) }
        end
      end

      module Schema
        include Devise::Schema

        SCHEMA_OPTIONS = {
          :null  => :required,
          :limit => :length
        }

        # Tell how to apply schema methods. This automatically maps :limit to
        # :length and :null to :required.
        def apply_schema(name, type, options={})
          SCHEMA_OPTIONS.each do |old_key, new_key|
            next unless options.key?(old_key)
            options[new_key] = options.delete(old_key)
          end

          options.delete(:default) if options[:default].nil?
          property name, type, options
        end
      end

      module Compatibility
        extend ActiveSupport::Concern

        module ClassMethods
          # Hooks for confirmable
          def before_create(*args)
            wrap_hook(:before, *args)
          end

          def after_create(*args)
            wrap_hook(:after, *args)
          end

          def wrap_hook(action, *args)
            options = args.extract_options!

            args.each do |callback|
              send action, :create, callback
              class_eval <<-METHOD, __FILE__, __LINE__ + 1
                def #{callback}
                  super if #{options[:if] || true}
                end
              METHOD
            end
          end

          # Add ActiveRecord like finder
          def find(*args)
            case args.first
            when :first, :all
              send(args.shift, *args)
            else
              get(*args)
            end
          end
        end

        def save(options=nil)
          if options.is_a?(Hash) && options[:validate] == false
            save!
          else
            super()
          end
        end
      end
    end
  end
end

DataMapper::Model.class_eval do
  include Devise::Models
  include Devise::Orm::DataMapper::Hook
end
