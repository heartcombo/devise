module Devise
  module Models
    autoload :Authenticatable, 'devise/models/authenticatable' 
    autoload :Confirmable, 'devise/models/confirmable' 
    autoload :Recoverable, 'devise/models/recoverable' 
    autoload :Rememberable, 'devise/models/rememberable'
    autoload :SessionSerializer, 'devise/models/session_serializer'
    autoload :Timeoutable, 'devise/models/timeoutable' 
    autoload :Trackable, 'devise/models/trackable' 
    autoload :Validatable, 'devise/models/validatable' 

    # Creates configuration values for Devise and for the given module.
    #
    #   Devise::Models.config(Devise::Authenticable, :stretches, 10)
    #
    # The line above creates:
    #
    #   1) An accessor called Devise.stretches, which value is used by default;
    #
    #   2) Some class methods for your model Model.stretches and Model.stretches=
    #      which have higher priority than Devise.stretches;
    #
    #   3) And an instance method stretches.
    #
    # To add the class methods you need to have a module ClassMethods defined
    # inside the given class.
    #
    def self.config(mod, *accessors) #:nodoc:
      accessors.each do |accessor|
        mod.class_eval <<-METHOD, __FILE__, __LINE__
          def #{accessor}
            if defined?(@#{accessor})
              @#{accessor}
            elsif superclass.respond_to?(:#{accessor})
              superclass.#{accessor}
            else
              Devise.#{accessor}
            end
          end

          def #{accessor}=(value)
            @#{accessor} = value
          end
        METHOD
      end
    end

    # Shortcut method for including all devise modules inside your model.
    # You can give some extra options while declaring devise in your model:
    #
    # * except: convenient option that allows you to add all devise modules,
    #   removing only the modules you setup here:
    #
    #    devise :all, :except => :rememberable
    #
    # You can also give the following configuration values in a hash: :pepper,
    # :stretches, :confirm_within and :remember_for. Please check your Devise
    # initialiazer for a complete description on those values.
    #
    # Examples:
    #
    #   # include only authenticatable module
    #   devise :authenticatable
    #
    #   # include authenticatable + confirmable modules
    #   devise :authenticatable, :confirmable
    #
    #   # include authenticatable + recoverable modules
    #   devise :authenticatable, :recoverable
    #
    #   # include authenticatable + rememberable + validatable modules
    #   devise :authenticatable, :rememberable, :validatable
    #
    #   # shortcut to include all available modules
    #   devise :all
    #
    #   # include all except recoverable
    #   devise :all, :except => :recoverable
    #
    def devise(*modules)
      raise "You need to give at least one Devise module" if modules.empty?

      options  = modules.extract_options!
      modules  = Devise.all if modules.include?(:all)
      modules -= Array(options.delete(:except))
      modules  = Devise::ALL & modules

      Devise.orm_class.included_modules_hook(self, modules) do
        modules.each do |m|
          devise_modules << m.to_sym
          include Devise::Models.const_get(m.to_s.classify)
        end

        options.each { |key, value| send(:"#{key}=", value) }
      end
    end

    # Stores all modules included inside the model, so we are able to verify
    # which routes are needed.
    def devise_modules
      @devise_modules ||= []
    end

    # Find an initialize a record setting an error if it can't be found
    def find_or_initialize_with_error_by(attribute, value, error=:invalid)
      if value.present?
        conditions = { attribute => value }
        record = find(:first, :conditions => conditions)
      end

      unless record
        record = new

        if value.present?
          record.send(:"#{attribute}=", value)
          record.errors.add(attribute, error, :default => error.to_s.gsub("_", " "))
        else
          record.errors.add(attribute, :blank)
        end
      end

      record
    end
  end
end
