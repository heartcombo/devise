begin
  require 'warden'
rescue
  gem 'warden'
  require 'warden'
end

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

require 'devise/warden'
require 'devise/routes'

# Ensure to include Devise modules only after Rails initialization.
# This way application should have already defined Devise mappings and we are
# able to create default filters.
Rails.configuration.after_initialize do
  ActiveRecord::Base.extend Devise::ActiveRecord
  ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Devise::Migrations
end
