module Devise
  CONTROLLERS = {
    :sessions => :authenticable,
    :passwords => :recoverable,
    :confirmations => :confirmable
  }.freeze

  class Mapping
    attr_reader :name, :as, :path_names

    def initialize(name, options)
      @as    = (options[:as] || name).to_sym
      @klass = (options[:class_name] || name.to_s.classify).to_s
      @name  = (options[:singular] || name.to_s.singularize).to_sym
      @path_names = options[:path_names] || {}
      [:sign_in, :sign_out, :password, :confirmation].each do |path_name|
        @path_names[path_name] ||= path_name.to_s
      end
    end

    # Return modules for the mapping.
    def for
      @for ||= to.devise_modules
    end

    # Reload mapped class each time when cache_classes is false.
    def to
      return @to if @to
      klass = @klass.constantize
      @to = klass if Rails.configuration.cache_classes
      klass
    end

    # Check if the respective controller has a module in the mapping class.
    def allows?(controller)
      self.for.include?(CONTROLLERS[controller.to_sym])
    end

    CONTROLLERS.values.each do |m|
      class_eval <<-METHOD, __FILE__, __LINE__
        def #{m}?
          self.for.include?(:#{m})
        end
      METHOD
    end
  end

  mattr_accessor :mappings
  self.mappings = {}

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
