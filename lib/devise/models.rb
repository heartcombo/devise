module Devise
  module Models
    class MissingAttribute < StandardError
      def initialize(attributes)
        @attributes = attributes
      end

      def message
        "The following attribute(s) is (are) missing on your model: #{@attributes.join(", ")}"
      end
    end

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

    def self.check_fields!(klass)
      failed_attributes = []

      klass.devise_modules.each do |mod|
        instance = klass.new

        if const_get(mod.to_s.classify).respond_to?(:required_fields)
          const_get(mod.to_s.classify).required_fields(klass).each do |field|
            failed_attributes << field unless instance.respond_to?(field)
          end
        else
          ActiveSupport::Deprecation.warn "The module #{mod} doesn't implement self.required_fields(klass). " \
            "Devise uses required_fields to warn developers of any missing fields in their models. " \
            "Please implement #{mod}.required_fields(klass) that returns an array of symbols with the required fields."
        end
      end

      if failed_attributes.any?
        fail Devise::Models::MissingAttribute.new(failed_attributes)
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
      options = modules.extract_options!.dup

      selected_modules = modules.map(&:to_sym).uniq.sort_by do |s|
        Devise::ALL.index(s) || -1  # follow Devise::ALL order
      end

      devise_modules_hook! do
        include Devise::Models::Authenticatable
        selected_modules.each do |m|
          if m == :encryptable && !(defined?(Devise::Models::Encryptable))
            warn "[DEVISE] You're trying to include :encryptable in your model but it is not bundled with the Devise gem anymore. Please add `devise-encryptable` to your Gemfile to proceed.\n"
          end

          mod = Devise::Models.const_get(m.to_s.classify)

          if mod.const_defined?("ClassMethods")
            class_mod = mod.const_get("ClassMethods")
            extend class_mod

            if class_mod.respond_to?(:available_configs)
              available_configs = class_mod.available_configs
              available_configs.each do |config|
                next unless options.key?(config)
                send(:"#{config}=", options.delete(config))
              end
            end
          end

          include mod
        end

        self.devise_modules |= selected_modules
        options.each { |key, value| send(:"#{key}=", value) }
      end
    end

    # The hook which is called inside devise.
    # So your ORM can include devise compatibility stuff.
    def devise_modules_hook!
      yield
    end
  end
end

require 'devise/models/authenticatable'
