module Devise
  module Models
    # Creates configuration values for Devise and for the given module.
    #
    #   Devise::Models.config(Devise::Authenticatable, :stretches, 10)
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
      (class << mod; self; end).send :attr_accessor, :available_configs
      mod.available_configs = accessors

      accessors.each do |accessor|
        mod.class_eval <<-METHOD, __FILE__, __LINE__ + 1
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

    # Include the chosen devise modules in your model:
    #
    #   devise :database_authenticatable, :confirmable, :recoverable
    #
    # You can also give any of the devise configuration values in form of a hash,
    # with specific values for this model. Please check your Devise initializer
    # for a complete description on those values.
    #
    def devise(*modules)
      include Devise::Models::Authenticatable
      options = modules.extract_options!.dup

      self.devise_modules += modules.map(&:to_sym).uniq.sort_by { |s|
        Devise::ALL.index(s) || -1  # follow Devise::ALL order
      }

      devise_modules_hook! do
        devise_modules.each do |m|
          mod = Devise::Models.const_get(m.to_s.classify)
          include mod

          if mod.const_defined?("ClassMethods")
            class_mod = mod.const_get("ClassMethods")
            if class_mod.respond_to?(:available_configs)
              available_configs = class_mod.available_configs
              available_configs.each do |config|
                next unless options.key?(config)                
                send(:"#{config}=", options.delete(config))
              end
            end
          end
        end

        options.each { |key, value| send(:"#{key}=", value) }
      end
    end

    # The hook which is called inside devise. So your ORM can include devise
    # compatibility stuff.
    def devise_modules_hook!
      yield
    end
  end
end

require 'devise/models/authenticatable'