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
    def self.config(mod, accessor, default=nil) #:nodoc:
      Devise.send :mattr_accessor, accessor
      Devise.send :"#{accessor}=", default

      mod.class_eval <<-METHOD, __FILE__, __LINE__
        def #{accessor}
          self.class.#{accessor}
        end
      METHOD

      mod.const_get(:ClassMethods).class_eval <<-METHOD, __FILE__, __LINE__
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

    # Shortcut method for including all devise modules inside your model.
    # You can give some extra options while declaring devise in your model:
    #
    # * except: convenient option that allows you to add all devise modules,
    #   removing only the modules you setup here:
    #
    #    devise :all, :except => :rememberable
    #
    # * pepper: setup a pepper to generate de encrypted password. By default no
    #   pepper is used:
    #
    #    devise :all, :pepper => 'my_pepper'
    #
    # * stretches: configure how many times you want the password is reencrypted.
    #
    #    devise :all, :stretches => 20
    #
    # * confirm_within: the time you want your user to confirm it's account. During
    #   this time he will be able to access your application without confirming.
    #
    #    devise :all, :confirm_within => 7.days
    #
    # * remember_for: the time the user will be remembered without asking for
    #   credentials again.
    #
    #    devise :all, :remember_for => 2.weeks
    #
    # You can refer to Authenticable, Confirmable and Rememberable for more
    # information about writing your own method to setup each model apart.
    #
    # Examples:
    #
    #   # include only authenticatable module (default)
    #   devise
    #
    #   # include authenticatable + confirmable modules
    #   devise :confirmable
    #
    #   # include authenticatable + recoverable modules
    #   devise :recoverable
    #
    #   # include authenticatable + rememberable modules
    #   devise :rememberable
    #
    #   # include authenticatable + validatable modules
    #   devise :validatable
    #
    #   # include authenticatable + confirmable + recoverable + rememberable + validatable
    #   devise :confirmable, :recoverable, :rememberable, :validatable
    #
    #   # shortcut to include all modules (same as above)
    #   devise :all
    #
    #   # include all except recoverable
    #   devise :all, :except => :recoverable
    #
    def devise(*modules)
      options  = modules.extract_options!

      modules  = Devise::ALL if modules.include?(:all)
      modules -= Array(options.delete(:except))
      modules  = [:authenticatable] | modules

      modules.each do |m|
        devise_modules << m.to_sym
        include Devise::Models.const_get(m.to_s.classify)
      end

      # Convert new keys to methods which overwrites Devise defaults
      options.each { |key, value| send(:"#{key}=", value) }
    end

    # Stores all modules included inside the model, so we are able to verify
    # which routes are needed.
    def devise_modules
      @devise_modules ||= []
    end
  end
end
