module Devise
  module Models
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
      # TODO Add this check in future versions
      # raise "You need to give at least one Devise module" if modules.empty?

      options  = modules.extract_options!
      modules  = Devise.all if modules.include?(:all)
      modules -= Array(options.delete(:except))
      modules  = Devise::ALL & modules

      if !modules.include?(:authenticatable)
        modules  = [:authenticatable] | modules
        ActiveSupport::Deprecation.warn ":authenticatable won't be included by default in devise in future versions, please add it", caller[0,10]
      end

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
  end
end
