module Devise
  module ActiveRecord
    # Shortcut method for including all devise modules inside your model
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

      modules  = Devise::ALL             if modules.include?(:all)
      modules -= Array(options[:except]) if options.key?(:except)
      modules |= [:authenticable]

      modules.each do |m|
        devise_modules << m.to_sym
        include Devise::Models.const_get(m.to_s.classify)
      end
    end

    # Stores all modules included inside the model, so we are able to verify
    # which routes are needed.
    def devise_modules
      @devise_modules ||= []
    end
  end
end
