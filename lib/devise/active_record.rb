module Devise
  module ActiveRecord
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
    # * confirm_in: the time you want your user to confirm it's account. During
    #   this time he will be able to access your application without confirming.
    #
    #    devise :all, :confirm_in => 7.days
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
    #   # include only authenticable module (default)
    #   devise
    #
    #   # include authenticable + confirmable modules
    #   devise :confirmable
    #
    #   # include authenticable + recoverable modules
    #   devise :recoverable
    #
    #   # include authenticable + rememberable modules
    #   devise :rememberable
    #
    #   # include authenticable + validatable modules
    #   devise :validatable
    #
    #   # include authenticable + confirmable + recoverable + rememberable + validatable
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
      modules |= [:authenticable]

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
