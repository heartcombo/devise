module Devise
  module Orm
    module DataMapper
      def self.included_modules_hook(klass, modules)
        klass.send :extend, self
        yield

        modules.each do |mod|
          klass.send(mod) if klass.respond_to?(mod)
        end
      end

      include Devise::Schema

      SCHEMA_OPTIONS = {
        :null  => :nullable,
        :limit => :length
      }

      # Hooks for confirmable
      def before_create(*args)
        before :create, *args
      end

      def after_create(*args)
        after :create, *args
      end

      # Add ActiveRecord like finder
      def find(*args)
        options = args.extract_options!
        case args.first
          when :first
            first(options)
          when :all
            all(options)
          else
            get(*args)
        end
      end

      # Tell how to apply schema methods. This automatically maps :limit to
      # :length and :null to :nullable.
      def apply_schema(name, type, options={})
        return unless Devise.apply_schema

        SCHEMA_OPTIONS.each do |old_key, new_key|
          next unless options.key?(old_key)
          options[new_key] = options.delete(old_key)
        end

        property name, type, options
      end
    end
  end
end

DataMapper::Model.send(:include, Devise::Models)
