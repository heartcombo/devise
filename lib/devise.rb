begin
  require 'warden'
rescue
  gem 'hassox-warden'
  require 'warden'
end

begin
  require 'rails_warden'
rescue
  gem 'hassox-rails_warden'
  require 'rails_warden'
end

require 'devise/initializers/warden'

module Devise
  class Mapping
    attr_accessor :resource, :as, :for

    def initialize(options={})
      @resource = options[:resource]
      @to = options[:to]
      @for = options[:for]
      @as = options[:as] || resource.to_s.pluralize
    end

    def to
      return @to if @to
      to = resource.to_s.classify.constantize
      @to = to if Rails.configuration.cache_classes
      to
    end

    def [](key)
      send(key)
    end
  end

  mattr_accessor :mappings
  self.mappings = {}.with_indifferent_access

  def self.map(mapping, options={})
    raise ArgumentError, "Need to provide :for option for Devise.map" unless options.key?(:for)
    options.assert_valid_keys(:to, :for, :as)
    mapping = mapping.to_s.singularize.to_sym
    mappings[mapping] = Mapping.new(options.merge(:resource => mapping))
    mappings.default = mapping if mappings.default.nil?
  end

  def self.find_mapping(map)
    map = map.to_s.split('/').reject(&:blank?).first
    map_sym = map.try(:to_sym)
    if mappings.key?(map_sym)
      mappings[map_sym]
    elsif mapping = mappings.detect{|m, options| options[:as] == map}.try(:first)
      mappings[mapping]
    else
      mappings[mappings.default]
    end
  end

  def self.resource_name(map)
    find_mapping(map).try(:resource).to_s
  end

  def self.resource_class(map)
    find_mapping(map).try(:to)
  end
end

ActiveRecord::Base.send :extend, Devise::ActiveRecord
ActionController::Base.send :include, Devise::ActionController
ActionView::Base.send :include, Devise::ActionView
