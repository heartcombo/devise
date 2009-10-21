module Devise
  ALL = [:authenticable, :confirmable, :recoverable, :rememberable, :validatable].freeze

  # Maps controller names to devise modules
  CONTROLLERS = {
    :sessions => :authenticable,
    :passwords => :recoverable,
    :confirmations => :confirmable
  }.freeze

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].freeze

  MODEL_CONFIG = []

  def self.model_config(klass, accessor, default=nil)
    # Create Devise accessor
    mattr_accessor accessor

    # Set default value
    send(:"#{accessor}=", default)

    # Store configuration method
    MODEL_CONFIG << accessor

    # Set default value
    klass.class_eval <<-METHOD
      def #{accessor}
        Devise.#{accessor}
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
require 'devise/routes'
