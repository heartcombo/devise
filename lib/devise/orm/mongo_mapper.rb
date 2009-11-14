module Devise
  module Orm
    module MongoMapper
      # Include attributes modules and set the proper ones.
      def self.included_modules_hook(klass, modules)
        klass.send :extend, self

        modules.each do |mod|
          klass.send(mod)
        end
      end

      include Devise::Schema

      # Tell how to apply schema methods.
      def apply_schema(name, type, options={})
        key name, type, options
      end
    end
  end
end

MongoMapper::Document::ClassMethods.send(:include, Devise::Models)