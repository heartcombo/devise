module Devise
  module ActiveRecord
    # Shortcut method for including all devise modules inside your User class
    # Examples:
    #   # include only authenticable module (default)
    #   devise
    #   # include authenticable + confirmable modules
    #   devise :confirmable
    #   # include authenticable + recoverable modules
    #   devise :recoverable
    #   # include authenticable + validatable modules
    #   devise :validatable
    #   # include all modules
    #   devise :confirmable, :recoverable, :validatable
    #   # shortcut to include all modules (same as above)
    #   devise :all
    #
    def devise(*options)
      include Devise::Models::Authenticable
      include Devise::Models::Confirmable if [:all, :confirmable].any?{|o| options.include?(o) }
      include Devise::Models::Recoverable if [:all, :recoverable].any?{|o| options.include?(o) }
      include Devise::Models::Validatable if [:all, :validatable].any?{|o| options.include?(o) }
    end
  end
end
