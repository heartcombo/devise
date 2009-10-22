module Devise
  ALL = [:authenticable, :confirmable, :recoverable, :rememberable, :validatable].freeze

  # Maps controller names to devise modules
  CONTROLLERS = {
    :sessions => :authenticable,
    :passwords => :recoverable,
    :confirmations => :confirmable
  }.freeze

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].freeze

  # Creates configuration values for Devise and for the given module.
  #
  #   Devise.model_config(Devise::Authenticable, :stretches, 10)
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
  def self.model_config(mod, accessor, default=nil) #:nodoc:
    mattr_accessor accessor
    send(:"#{accessor}=", default)

    mod.class_eval <<-METHOD, __FILE__, __LINE__
      def #{accessor}
        self.class.#{accessor}
      end
    METHOD

    mod.const_get(:ClassMethods).class_eval <<-METHOD, __FILE__, __LINE__
      def #{accessor}
        @#{accessor} || if superclass.respond_to?(:#{accessor})
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

# Devise initialization process goes like this:
#
#   1) Include Devise::ActiveRecord and Devise::Migrations
#   2) Load and config warden
#   3) Add routes extensions
#   4) Load routes definitions
#   5) Include filters and helpers in controllers and views
#
Rails.configuration.after_initialize do
  ActiveRecord::Base.extend Devise::ActiveRecord
  ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Devise::Migrations
end

require 'devise/warden'
require 'devise/mapping'
require 'devise/routes'
