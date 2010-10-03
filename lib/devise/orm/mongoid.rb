module Devise
  module Orm
    module Mongoid
      module Hook
        def devise_modules_hook!
          extend Schema
          yield
          return unless Devise.apply_schema
          devise_modules.each { |m| send(m) if respond_to?(m, true) }
        end
      end

      module Schema
        include Devise::Schema

        # Tell how to apply schema methods
        def apply_devise_schema(name, type, options={})
          type = Time if type == DateTime
          field name, { :type => type }.merge!(options)
        end
      end

      module Finders
        def devise_find_first_by_identifier(id)
          find(:first, :conditions => {:id => Array(id).first})
        end

        def devise_find_first_with_conditions(conditions)
          find(:first, :conditions => conditions)
        end
      end
    end
  end
end

Mongoid::Document::ClassMethods.class_eval do
  include Devise::Models
  include Devise::Orm::Mongoid::Hook
  include Devise::Orm::Mongoid::Finders
end
