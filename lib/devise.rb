require 'active_support/core_ext/numeric/time'

module Devise
  autoload :FailureApp, 'devise/failure_app'
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
    autoload :Bcrypt, 'devise/encryptors/bcrypt'
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
  # not be modified by the "end user".
  ALL            = []
  CONTROLLERS    = ActiveSupport::OrderedHash.new
  ROUTES         = ActiveSupport::OrderedHash.new
  STRATEGIES     = ActiveSupport::OrderedHash.new
  FLASH_MESSAGES = [:unauthenticated]

  # True values used to check params
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']

  # Declare encryptors length which are used in migrations.
  ENCRYPTORS_LENGTH = {
    :sha1   => 40,
    :sha512 => 128,
    :clearance_sha1 => 40,
    :restful_authentication_sha1 => 40,
    :authlogic_sha512 => 128,
    :bcrypt => 60
  }

  # Used to encrypt password. Please generate one with rake secret.
  mattr_accessor :pepper
  @@pepper = nil

  # The number of times to encrypt password.
  mattr_accessor :stretches
  @@stretches = 10

  # Keys used when authenticating an user.
  mattr_accessor :authentication_keys
  @@authentication_keys = [ :email ]

  # If http authentication is enabled by default.
  mattr_accessor :http_authenticatable
  @@http_authenticatable = true

  # The realm used in Http Basic Authentication.
  mattr_accessor :http_authentication_realm
  @@http_authentication_realm = "Application"

  # Email regex used to validate email formats. Adapted from authlogic.
  mattr_accessor :email_regexp
  @@email_regexp = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i

  # Range validation for password length
  mattr_accessor :password_length
  @@password_length = 6..20

  # Time interval where the remember me token is valid.
  mattr_accessor :remember_for
  @@remember_for = 2.weeks

  # Time interval you can access your account before confirming your account.
  mattr_accessor :confirm_within
  @@confirm_within = 0.days

  # Time interval to timeout the user session without activity.
  mattr_accessor :timeout_in
  @@timeout_in = 30.minutes

  # Used to define the password encryption algorithm.
  mattr_accessor :encryptor
  @@encryptor = :sha1

  # Store scopes mappings.
  mattr_accessor :mappings
  @@mappings = ActiveSupport::OrderedHash.new

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

  # Tell when to use the default scope, if one cannot be found from routes.
  mattr_accessor :use_default_scope
  @@use_default_scope = false

  # The default scope which is used by warden.
  mattr_accessor :default_scope
  @@default_scope = nil

  # Address which sends Devise e-mails.
  mattr_accessor :mailer_sender
  @@mailer_sender = nil

  # Authentication token params key name of choice. E.g. /users/sign_in?some_key=...
  mattr_accessor :token_authentication_key
  @@token_authentication_key = :auth_token

  # Private methods to interface with Warden.
  mattr_accessor :warden_config
  @@warden_config = nil
  @@warden_config_block = nil

  # Default way to setup Devise. Run rails generate devise_install to create
  # a fresh initializer with all configuration values.
  def self.setup
    yield self
  end

  # Register a model in Devise. You can call this manually if you don't want
  # to use devise routes. Check devise_for in routes to know which options
  # are available.
  def self.register(resource, options)
    mapping = Devise::Mapping.new(resource, options)
    self.mappings[mapping.name] = mapping
    self.default_scope ||= mapping.name

    warden_config.default_scope ||= mapping.name
    warden_config.scope_defaults mapping.name, :strategies => mapping.strategies
    mapping
  end

  # Make Devise aware of an 3rd party Devise-module. For convenience.
  #
  # == Options:
  #
  #   +model+      - String representing the load path to a custom *model* for this module (to autoload.)
  #   +controller+ - Symbol representing the name of an exisiting or custom *controller* for this module.
  #   +route+      - Symbol representing the named *route* helper for this module.
  #   +flash+      - Symbol representing the *flash messages* used by this helper.
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
    options.assert_valid_keys(:strategy, :model, :controller, :route, :flash, :passive_strategy)

    config = {
      :strategy => STRATEGIES,
      :flash => FLASH_MESSAGES,
      :route => ROUTES,
      :controller => CONTROLLERS
    }

    config.each do |key, value|
      next unless options[key]
      name = (options[key] == true ? module_name : options[key])

      if value.is_a?(Hash)
        value[module_name] = name
      else
        value << name unless value.include?(name)
      end
    end

    if options[:model]
      model_path = (options[:model] == true ? "devise/models/#{module_name}" : options[:model])
      Devise::Models.send(:autoload, module_name.to_s.camelize.to_sym, model_path)
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

  # A method used internally to setup warden manager from the Rails initialize
  # block.
  def self.configure_warden! #:nodoc:
    @@warden_config_block.try :call, Devise.warden_config
  end

  # Generate a friendly string randomically to be used as token.
  def self.friendly_token
    ActiveSupport::SecureRandom.base64(15).tr('+/=', '-_ ').strip.delete("\n")
  end
end

require 'warden'
require 'devise/mapping'
require 'devise/models'
require 'devise/modules'
require 'devise/rails'
