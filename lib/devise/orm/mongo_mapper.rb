module Devise
  module Orm
    module MongoMapper
      module InstanceMethods
        def save(options={})
          if options == false
            super(:validate => false)
          else
            super
          end
        end
      end

      def self.included_modules_hook(klass)
        klass.send :extend,  self
        klass.send :include, InstanceMethods
        yield

        klass.devise_modules.each do |mod|
          klass.send(mod) if klass.respond_to?(mod)
        end
      end
      
      def find(*args)
        case args.first
        when :first, :all
          send(args.shift, *args)
        else
          super
        end
      end
      
      include Devise::Schema

      # Tell how to apply schema methods. This automatically converts DateTime
      # to Time, since MongoMapper does not recognize the former.
      def apply_schema(name, type, options={})
        return unless Devise.apply_schema
        type = Time if type == DateTime
        key name, type, options
      end
    end
  end
end

if MongoMapper::Version >= "0.8.0"
  MongoMapper::Plugins::Document::ClassMethods.send(:include, Devise::Models)
  MongoMapper::Plugins::EmbeddedDocument::ClassMethods.send(:include, Devise::Models)
else
  MongoMapper::Document::ClassMethods.send(:include, Devise::Models)
  MongoMapper::EmbeddedDocument::ClassMethods.send(:include, Devise::Models)
end