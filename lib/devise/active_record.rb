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
      include Devise::Models::Authenticable
      include Devise::Models::Confirmable unless ([:all, :confirmable] & options).empty?
      include Devise::Models::Recoverable unless ([:all, :recoverable] & options).empty?
      include Devise::Models::Validatable unless ([:all, :validatable] & options).empty?
    end
  end
end
