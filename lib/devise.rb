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

  mattr_accessor :mappings
  self.mappings = {}.with_indifferent_access

  def self.map(mapping, options={})
    raise ArgumentError, "Need to provide :for option for Devise.map" unless options.key?(:for)
    options.assert_valid_keys(:to, :for, :as)
    mapping = mapping.to_s
    options[:as] ||= mapping.pluralize
    mapping = mapping.singularize
    options[:to] ||= mapping.camelize.constantize
    mapping = mapping.to_sym
    mappings[mapping] = options
    mappings.default = mapping if mappings.default.nil?
  end

  def self.find_mapping(map)
    if mappings.key?(map.try(:to_sym))
      map
    elsif mapping = mappings.detect{|m, options| options[:as] == map}.try(:first)
      mapping
    else
      mappings.default
    end.to_s
  end

  def self.resource_name(map)
    find_mapping(map)
  end

  def self.resource_class(map)
    mappings[resource_name(map).to_sym].try(:fetch, :to, nil)
  end
end

ActiveRecord::Base.send :extend, Devise::ActiveRecord
ActionController::Base.send :include, Devise::ActionController
ActionView::Base.send :include, Devise::ActionView
