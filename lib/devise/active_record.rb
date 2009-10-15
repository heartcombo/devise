module Devise
  module ActiveRecord
    # Shortcut method for including all devise modules inside your User class
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
    #   # include authenticable + validatable modules
    #   devise :validatable
    #
    #   # include all modules
    #   devise :confirmable, :recoverable, :validatable
    #
    #   # shortcut to include all modules (same as above)
    #   devise :all
    #
    def devise(*options)
      options  = [:confirmable, :recoverable, :validatable] if options.include?(:all)
      options |= [:authenticable]
      options |= [:perishable] if options.include?(:confirmable) || options.include?(:recoverable)

      options.each do |m|
        devise_modules << m.to_sym
        include Devise::Models.const_get(m.to_s.classify)
      end
    end

    def devise_modules
      @devise_modules ||= []
    end
  end
end
