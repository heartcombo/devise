module Devise
  module Orm
    module MongoMapper
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

        # Tell how to apply schema methods. This automatically converts DateTime
        # to Time, since MongoMapper does not recognize the former.
        def apply_schema(name, type, options={})
          type = Time if type == DateTime
          key name, type, options
        end
      end

      module Compatibility
        extend ActiveSupport::Concern

        module ClassMethods
          def find(*args)
            case args.first
            when :first, :all
              send(args.shift, *args)
            else
              super
            end
          end
        end
      end

    end
  end
end

[MongoMapper::Document, MongoMapper::EmbeddedDocument].each do |mod|
  mod::ClassMethods.class_eval do
    include Devise::Models
    include Devise::Orm::MongoMapper::Hook
  end
end