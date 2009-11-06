module Devise
  # Responsible for handling devise mappings and routes configuration. Each
  # resource configured by devise_for in routes is actually creating a mapping
  # object. You can refer to devise_for in routes for usage options.
  #
  # The required value in devise_for is actually not used internally, but it's
  # inflected to find all other values.
  #
  #   map.devise_for :users
  #   mapping = Devise.mappings[:user]
  #
  #   mapping.name #=> :user
  #   # is the scope used in controllers and warden, given in the route as :singular.
  #
  #   mapping.as   #=> "users"
  #   # how the mapping should be search in the path, given in the route as :as.
  #
  #   mapping.to   #=> User
  #   # is the class to be loaded from routes, given in the route as :class_name.
  #
  #   mapping.for  #=> [:authenticatable]
  #   # is the modules included in the class
  #
  class Mapping #:nodoc:
    attr_reader :name, :as, :path_names, :path_prefix

    # Loop through all mappings looking for a map that matches with the requested
    # path (ie /users/sign_in). If a path prefix is given, it's taken into account.
    def self.find_by_path(path)
      Devise.mappings.each_value do |mapping|
        route = path.split("/")[mapping.as_position]
        return mapping if mapping.as == route.to_sym
      end
      nil
    end

    def initialize(name, options)
      options.assert_valid_keys(:class_name, :as, :path_names, :singular, :path_prefix)

      @as    = (options[:as] || name).to_sym
      @klass = (options[:class_name] || name.to_s.classify).to_s
      @name  = (options[:singular] || name.to_s.singularize).to_sym
      @path_names  = options[:path_names] || {}
      @path_prefix = options[:path_prefix] || ""
      @path_prefix << "/" unless @path_prefix[-1] == ?/

      setup_path_names
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

    # Return in which position in the path prefix devise should find the as mapping.
    def as_position
      self.path_prefix.count("/")
    end

    # Returns the raw path using path_prefix and as.
    def raw_path
      path_prefix + as.to_s
    end

    # Returns the parsed path. If you need meta information in your path_prefix,
    # you should overwrite this method to use it. The only information supported
    # by default is I18n.locale.
    #
    # TODO This is a hack. Setting default_url_options that are shared by
    # controllers and devise seems to be the best solution.
    def parsed_path
      raw_path.gsub(":locale", I18n.locale.to_s)
    end

    # Create magic predicates for verifying what module is activated by this map.
    # Example:
    #
    #   def confirmable?
    #     self.for.include?(:confirmable)
    #   end
    #
    ALL.each do |m|
      class_eval <<-METHOD, __FILE__, __LINE__
        def #{m}?
          self.for.include?(:#{m})
        end
      METHOD
    end

    private

      # Configure default path names, allowing the user overwrite defaults by
      # passing a hash in :path_names.
      def setup_path_names
        [:sign_in, :sign_out, :password, :confirmation].each do |path_name|
          @path_names[path_name] ||= path_name.to_s
        end
      end
  end
end
