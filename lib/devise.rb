module Devise
  ALL = [:authenticatable, :confirmable, :recoverable, :rememberable, :validatable].freeze

  # Maps controller names to devise modules
  CONTROLLERS = {
    :sessions => :authenticatable,
    :passwords => :recoverable,
    :confirmations => :confirmable
  }.freeze

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].freeze
end

# Devise initialization process goes like this:
#
#   1) Includes in Devise::ActiveRecord and Devise::Migrations
#   2) Load and config warden
#   3) Load devise mapping structure
#   4) Add routes extensions
#   5) Load routes definitions
#   6) Include filters and helpers in controllers and views
#
Rails.configuration.after_initialize do
  if defined?(ActiveRecord)
    ActiveRecord::Base.extend Devise::Models
    ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Devise::Migrations
  end

  I18n.load_path.unshift File.expand_path(File.join(File.dirname(__FILE__), 'devise', 'locales', 'en.yml'))
end

require 'devise/warden'
require 'devise/mapping'
require 'devise/routes'
