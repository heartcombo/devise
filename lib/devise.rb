require 'active_support/core_ext/numeric/time'
require 'active_support/dependencies'
require 'orm_adapter'
require 'set'

module Devise
  autoload :FailureApp, 'devise/failure_app'
  autoload :OmniAuth, 'devise/omniauth'
  autoload :PathChecker, 'devise/path_checker'
  autoload :Schema, 'devise/schema'
  autoload :TestHelpers, 'devise/test_helpers'

  module Controllers
    autoload :Helpers, 'devise/controllers/helpers'
    autoload :InternalHelpers, 'devise/controllers/internal_helpers'
    autoload :ScopedViews, 'devise/controllers/scoped_views'
    autoload :UrlHelpers, 'devise/controllers/url_helpers'
  end

  module Encryptors
    autoload :Base, 'devise/encryptors/base'
    autoload :AuthlogicSha512, 'devise/encryptors/authlogic_sha512'
    autoload :ClearanceSha1, 'devise/encryptors/clearance_sha1'
    autoload :RestfulAuthenticationSha1, 'devise/encryptors/restful_authentication_sha1'
    autoload :Sha512, 'devise/encryptors/sha512'
    autoload :Sha1, 'devise/encryptors/sha1'
  end

  module Strategies
    autoload :Base, 'devise/strategies/base'
    autoload :Authenticatable, 'devise/strategies/authenticatable'
  end

  # Constants which holds devise configuration for extensions. Those should
  # not be modified by the "end user" (this is why they are constants).
  ALL         = []
  CONTROLLERS = ActiveSupport::OrderedHash.new
  ROUTES      = ActiveSupport::OrderedHash.new
  STRATEGIES  = ActiveSupport::OrderedHash.new
  URL_HELPERS = ActiveSupport::OrderedHash.new

  # True values used to check params
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']

  # Declare encryptors length which are used in migrations.
  ENCRYPTORS_LENGTH = {
    :sha1   => 40,
    :sha512 => 128,
    :clearance_sha1 => 40,
    :restful_authentication_sha1 => 40,
    :authlogic_sha512 => 128
  }

  # Custom domain for cookies. Not set by default
  mattr_accessor :cookie_options
  @@cookie_options = {}

  # The number of times to encrypt password.
  mattr_accessor :stretches
  @@stretches = 10

  # Keys used when authenticating a user.
  mattr_accessor :authentication_keys
  @@authentication_keys = [ :email ]

  # Request keys used when authenticating a user.
  mattr_accessor :request_keys
  @@request_keys = []

  # Keys that should be case-insensitive.
  # Empty by default for backwards compaibility.
  mattr_accessor :case_insensitive_keys
  @@case_insensitive_keys = [ ]

  # If http authentication is enabled by default.
  mattr_accessor :http_authenticatable
  @@http_authenticatable = false

  # If http headers should be returned for ajax requests. True by default.
  mattr_accessor :http_authenticatable_on_xhr
  @@http_authenticatable_on_xhr = true

  # If params authenticatable is enabled by default.
  mattr_accessor :params_authenticatable
  @@params_authenticatable = true

  # The realm used in Http Basic Authentication.
  mattr_accessor :http_authentication_realm
  @@http_authentication_realm = "Application"

  # Email regex used to validate email formats. Adapted from authlogic.
  mattr_accessor :email_regexp
  @@email_regexp = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i

  # Range validation for password length
  mattr_accessor :password_length
  @@password_length = 6..20

  # The time the user will be remembered without asking for credentials again.
  mattr_accessor :remember_for
  @@remember_for = 2.weeks

  # If true, a valid remember token can be re-used between multiple browsers.
  mattr_accessor :remember_across_browsers
  @@remember_across_browsers = true

  # If true, extends the user's remember period when remembered via cookie.
  mattr_accessor :extend_remember_period
  @@extend_remember_period = false

  # If true, uses salt as remember token and does not create it in the database.
  # By default is false for backwards compatibility.
  mattr_accessor :use_salt_as_remember_token
  @@use_salt_as_remember_token = false

  # Time interval you can access your account before confirming your account.
  mattr_accessor :confirm_within
  @@confirm_within = 0.days

  # Time interval to timeout the user session without activity.
  mattr_accessor :timeout_in
  @@timeout_in = 30.minutes

  # Used to encrypt password. Please generate one with rake secret.
  mattr_accessor :pepper
  @@pepper = nil

  # Used to define the password encryption algorithm.
  mattr_accessor :encryptor
  @@encryptor = nil

  # Tells if devise should apply the schema in ORMs where devise declaration
  # and schema belongs to the same class (as Datamapper and Mongoid).
  mattr_accessor :apply_schema
  @@apply_schema = true

  # Scoped views. Since it relies on fallbacks to render default views, it's
  # turned off by default.
  mattr_accessor :scoped_views
  @@scoped_views = false

  # Defines which strategy can be used to lock an account.
  # Values: :failed_attempts, :none
  mattr_accessor :lock_strategy
  @@lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  mattr_accessor :unlock_keys
  @@unlock_keys = [ :email ]

  # Defines which strategy can be used to unlock an account.
  # Values: :email, :time, :both
  mattr_accessor :unlock_strategy
  @@unlock_strategy = :both

  # Number of authentication tries before locking an account
  mattr_accessor :maximum_attempts
  @@maximum_attempts = 20

  # Time interval to unlock the account if :time is defined as unlock_strategy.
  mattr_accessor :unlock_in
  @@unlock_in = 1.hour

  # Defines which key will be used when recovering the password for an account
  mattr_accessor :reset_password_keys
  @@reset_password_keys = [ :email ]

  # The default scope which is used by warden.
  mattr_accessor :default_scope
  @@default_scope = nil

  # Address which sends Devise e-mails.
  mattr_accessor :mailer_sender
  @@mailer_sender = nil

  # Authentication token params key name of choice. E.g. /users/sign_in?some_key=...
  mattr_accessor :token_authentication_key
  @@token_authentication_key = :auth_token

  # If true, authentication through token does not store user in session
  mattr_accessor :stateless_token
  @@stateless_token = false

  # Which formats should be treated as navigational.
  mattr_accessor :navigational_formats
  @@navigational_formats = [:"*/*", :html]

  # When set to true, signing out an user signs out all other scopes.
  mattr_accessor :sign_out_all_scopes
  @@sign_out_all_scopes = true

  # The default method used while signing out
  mattr_accessor :sign_out_via
  @@sign_out_via = :get

  # PRIVATE CONFIGURATION

  # Store scopes mappings.
  mattr_reader :mappings
  @@mappings = ActiveSupport::OrderedHash.new

  # Omniauth configurations.
  mattr_reader :omniauth_configs
  @@omniauth_configs = ActiveSupport::OrderedHash.new

  # Define a set of modules that are called when a mapping is added.
  mattr_reader :helpers
  @@helpers = Set.new
  @@helpers << Devise::Controllers::Helpers

  # Private methods to interface with Warden.
  mattr_accessor :warden_config
  @@warden_config = nil
  @@warden_config_block = nil

  # Default way to setup Devise. Run rails generate devise_install to create
  # a fresh initializer with all configuration values.
  def self.setup
    yield self
  end

  def self.omniauth_providers
    omniauth_configs.keys
  end

  def self.cookie_domain=(value)
    ActiveSupport::Deprecation.warn "Devise.cookie_domain=(value) is deprecated. "
      "Please use Devise.cookie_options = { :domain => value } instead."
    self.cookie_options[:domain] = value
  end

  # Get the mailer class from the mailer reference object.
  def self.mailer
    @@mailer_ref.get
  end

  # Set the mailer reference object to access the mailer.
  def self.mailer=(class_name)
    @@mailer_ref = ActiveSupport::Dependencies.ref(class_name)
  end
  self.mailer = "Devise::Mailer"

  # Small method that adds a mapping to Devise.
  def self.add_mapping(resource, options)
    mapping = Devise::Mapping.new(resource, options)
    @@mappings[mapping.name] = mapping
    @@default_scope ||= mapping.name
    @@helpers.each { |h| h.define_helpers(mapping) }
    mapping
  end

  # Make Devise aware of an 3rd party Devise-module (like invitable). For convenience.
  #
  # == Options:
  #
  #   +model+      - String representing the load path to a custom *model* for this module (to autoload.)
  #   +controller+ - Symbol representing the name of an exisiting or custom *controller* for this module.
  #   +route+      - Symbol representing the named *route* helper for this module.
  #   +strategy+   - Symbol representing if this module got a custom *strategy*.
  #
  # All values, except :model, accept also a boolean and will have the same name as the given module
  # name.
  #
  # == Examples:
  #
  #   Devise.add_module(:party_module)
  #   Devise.add_module(:party_module, :strategy => true, :controller => :sessions)
  #   Devise.add_module(:party_module, :model => 'party_module/model')
  #
  def self.add_module(module_name, options = {})
    ALL << module_name
    options.assert_valid_keys(:strategy, :model, :controller, :route)

    if strategy = options[:strategy]
      STRATEGIES[module_name] = (strategy == true ? module_name : strategy)
    end

    if controller = options[:controller]
      CONTROLLERS[module_name] = (controller == true ? module_name : controller)
    end

    if route = options[:route]
      case route
      when TrueClass
        key, value = module_name, []
      when Symbol
        key, value = route, []
      when Hash
        key, value = route.keys.first, route.values.flatten
      else
        raise ArgumentError, ":route should be true, a Symbol or a Hash"
      end

      URL_HELPERS[key] ||= []
      URL_HELPERS[key].concat(value)
      URL_HELPERS[key].uniq!

      ROUTES[module_name] = key
    end

    if options[:model]
      path = (options[:model] == true ? "devise/models/#{module_name}" : options[:model])
      Devise::Models.send(:autoload, module_name.to_s.camelize.to_sym, path)
    end

    Devise::Mapping.add_module module_name
  end

  # Sets warden configuration using a block that will be invoked on warden
  # initialization.
  #
  #  Devise.initialize do |config|
  #    config.confirm_within = 2.days
  #
  #    config.warden do |manager|
  #      # Configure warden to use other strategies, like oauth.
  #      manager.oauth(:twitter)
  #    end
  #  end
  def self.warden(&block)
    @@warden_config_block = block
  end

  # Specify an omniauth provider.
  #
  #   config.omniauth :github, APP_ID, APP_SECRET
  #
  def self.omniauth(provider, *args)
    @@helpers << Devise::OmniAuth::UrlHelpers
    @@omniauth_configs[provider] = Devise::OmniAuth::Config.new(provider, args)
  end

  # Include helpers in the given scope to AC and AV.
  def self.include_helpers(scope)
    ActiveSupport.on_load(:action_controller) do
      include scope::Helpers if defined?(scope::Helpers)
      include scope::UrlHelpers
    end

    ActiveSupport.on_load(:action_view) do
      include scope::UrlHelpers
    end
  end

  # Returns true if Rails version is bigger than 3.0.x
  def self.rack_session?
    Rails::VERSION::STRING[0,3] != "3.0"
  end

  # A method used internally to setup warden manager from the Rails initialize
  # block.
  def self.configure_warden! #:nodoc:
    @@warden_configured ||= begin
      warden_config.failure_app   = Devise::FailureApp
      warden_config.default_scope = Devise.default_scope
      warden_config.intercept_401 = false

      Devise.mappings.each_value do |mapping|
        warden_config.scope_defaults mapping.name, :strategies => mapping.strategies
      end

      @@warden_config_block.try :call, Devise.warden_config
      true
    end
  end

  # Generate a friendly string randomically to be used as token.
  def self.friendly_token
    ActiveSupport::SecureRandom.base64(44).tr('+/=', 'xyz')
  end
end

require 'warden'
require 'devise/mapping'
require 'devise/models'
require 'devise/modules'
require 'devise/rails'
