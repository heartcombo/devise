begin
  require 'warden'
rescue
  gem 'hassox-warden'
  require 'warden'
end

require 'devise/initializers/warden'

module Devise
  class Mapping
    attr_reader :name, :as, :for

    def initialize(name, options)
      @name  = name
      @for   = Array(options[:for])
      @klass = (options[:to] || name.to_s.classify).to_s
      @as    = (options[:as] || name.to_s.pluralize).to_sym
    end

    # Reload mapped class each time when cache_classes is false.
    #
    def to
      return @to if @to
      klass = @klass.constantize
      @to = klass if Rails.configuration.cache_classes
      klass
    end
  end

  mattr_accessor :mappings
  self.mappings = {}

  def self.map(mapping, options={})
    raise ArgumentError, "Need to provide :for option for Devise.map" unless options.key?(:for)
    options.assert_valid_keys(:to, :for, :as)
    self.mappings[mapping] = Mapping.new(mapping, options)
  end

  # TODO Test me
  def self.find_mapping_by_path(path)
    route = path.split("/")[1]
    return nil unless route

    route = route.to_sym
    mappings.each do |key, map|
      return map if map.as == route.to_sym
    end
    nil
  end
end

# Ensure to include Devise modules only after Rails initialization.
# This way application should have already defined Devise mappings and we are
# able to create default filters.
#
Rails.configuration.after_initialize do
  ActiveRecord::Base.send :extend, Devise::ActiveRecord
  ActionController::Base.send :include, Devise::ActionController
  ActionView::Base.send :include, Devise::ActionView
end
