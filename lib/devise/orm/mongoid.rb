module Devise
  module Orm
    module Mongoid
      module Hook
        def devise_modules_hook!
          extend Schema
          include ::Mongoid::Timestamps
          include Compatibility
          yield
          return unless Devise.apply_schema
          devise_modules.each { |m| send(m) if respond_to?(m, true) }
        end
      end
      
      module Schema
        include Devise::Schema

        # Tell how to apply schema methods
        def apply_schema(name, type, options={})
          type = Time if type == DateTime
          field name, { :type => type }.merge(options)
        end
      end
      
      module Compatibility
        def save(validate = true)
          if validate.is_a?(Hash) && validate.has_key?(:validate)
            validate = validate[:validate]
          end
          super(validate)
        end
      end
    end
  end
end

Mongoid::Document::ClassMethods.class_eval do
  include Devise::Models
  include Devise::Orm::Mongoid::Hook
end