module Devise
  CONTROLLERS = {
    :sessions => :authenticable,
    :passwords => :recoverable,
    :confirmations => :confirmable
  }.freeze

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

    CONTROLLERS.values.each do |m|
      class_eval <<-METHOD, __FILE__, __LINE__
        def #{m}?
          @for.include?(:#{m})
        end
      METHOD
    end

    def allows?(controller)
      @for.include?(CONTROLLERS[controller.to_sym])
    end
  end

  mattr_accessor :mappings
  self.mappings = {}

  def self.map(mapping, options={})
    raise ArgumentError, "Need to provide :for option for Devise.map" unless options.key?(:for)
    options.assert_valid_keys(:to, :for, :as)
    self.mappings[mapping] = Mapping.new(mapping, options)
  end

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
