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
  self.mappings = {}

  def self.map(mapping, options={})
    raise ArgumentError, "Need to provide :for option for Devise.map" unless options.key?(:for)
    options.assert_valid_keys(:to, :for, :as)
    options[:as] ||= mapping
    options[:to] ||= mapping.to_s.singularize.camelize.constantize
    mappings[mapping.to_sym] = options
    mappings.default = mapping.to_sym if mappings.default.nil?
  end

  def self.find_mapping(map)
    if map.present? && mappings.key?(map.to_sym)
      map
    elsif mapping = mappings.detect{|m, options| options[:as] == map}.try(:first)
      mapping
    else
      mappings.default
    end.to_s
  end
end

ActionView::Base.send :include, DeviseHelper
ActionView::Base.send :include, Devise::Controllers::UrlHelpers
ActionController::Base.send :include, Devise::Controllers::Authenticable
ActionController::Base.send :include, Devise::Controllers::UrlHelpers
ActiveRecord::Base.send :extend, Devise::ActiveRecord
