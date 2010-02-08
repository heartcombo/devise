module Devise
  autoload :FailureApp, 'devise/failure_app'
  autoload :Schema, 'devise/schema'
  autoload :TestHelpers, 'devise/test_helpers'

  module Controllers
    autoload :Common, 'devise/controllers/common'
    autoload :Helpers, 'devise/controllers/helpers'
    autoload :InternalHelpers, 'devise/controllers/internal_helpers'
    autoload :UrlHelpers, 'devise/controllers/url_helpers'
  end

  module Encryptors
    autoload :Base, 'devise/encryptors/base'
    autoload :Bcrypt, 'devise/encryptors/bcrypt'
    autoload :AuthlogicSha512, 'devise/encryptors/authlogic_sha512'
    autoload :AuthlogicSha1, 'devise/encryptors/authlogic_sha1'
    autoload :RestfulAuthenticationSha1, 'devise/encryptors/restful_authentication_sha1'
    autoload :Sha512, 'devise/encryptors/sha512'
    autoload :Sha1, 'devise/encryptors/sha1'
  end

  module Orm
    autoload :ActiveRecord, 'devise/orm/active_record'
    autoload :DataMapper, 'devise/orm/data_mapper'
    autoload :MongoMapper, 'devise/orm/mongo_mapper'
  end

  ALL = []

  # Authentication ones first
  ALL.push :authenticatable, :token_authenticatable, :rememberable

  # Misc after
  ALL.push :recoverable, :registerable, :validatable

  # The ones which can sign out after
  ALL.push :activatable, :confirmable, :lockable, :timeoutable

  # Stats for last, so we make sure the user is really signed in
  ALL.push :trackable

  # Maps controller names to devise modules.
  CONTROLLERS = {
    :sessions => [:authenticatable, :token_authenticatable],
    :passwords => [:recoverable],
    :confirmations => [:confirmable],
    :registrations => [:registerable],
    :unlocks => [:lockable]
  }

  # Routes for generating url helpers.
  ROUTES = [:session, :password, :confirmation, :registration, :unlock]

  # Path names used in routes.
  PATH_NAMES = [:sign_in, :sign_out, :sign_up, :password, :confirmation, :unlock]

  STRATEGIES  = [:rememberable, :http_authenticatable, :token_authenticatable, :authenticatable]

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']

  # Maps the messages types that are used in flash message.
  FLASH_MESSAGES = [:unauthenticated, :unconfirmed, :invalid, :invalid_token, :timeout, :inactive, :locked]

  # Declare encryptors length which are used in migrations.
  ENCRYPTORS_LENGTH = {
    :sha1   => 40,
    :sha512 => 128,
    :clearance_sha1 => 40,
    :restful_authentication_sha1 => 40,
    :authlogic_sha512 => 128,
    :bcrypt => 60
  }

  # Email regex used to validate email formats. Adapted from authlogic.
  EMAIL_REGEX = /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i

  # Used to encrypt password. Please generate one with rake secret.
  mattr_accessor :pepper
  @@pepper = nil

  # The number of times to encrypt password.
  mattr_accessor :stretches
  @@stretches = 10

  # Keys used when authenticating an user.
  mattr_accessor :authentication_keys
  @@authentication_keys = [ :email ]

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

  # Stores the chosen ORM.
  mattr_accessor :orm
  @@orm = :active_record

  # TODO Remove
  mattr_accessor :all
  @@all = []

  # Tells if devise should apply the schema in ORMs where devise declaration
  # and schema belongs to the same class (as Datamapper and MongoMapper).
  mattr_accessor :apply_schema
  @@apply_schema = true

  # Scoped views. Since it relies on fallbacks to render default views, it's
  # turned off by default.
  mattr_accessor :scoped_views
  @@scoped_views = false

  # Number of authentication tries before locking an account
  mattr_accessor :maximum_attempts
  @@maximum_attempts = 20

  # Defines which strategy can be used to unlock an account.
  # Values: :email, :time, :both
  mattr_accessor :unlock_strategy
  @@unlock_strategy = :both

  # Time interval to unlock the account if :time is defined as unlock_strategy.
  mattr_accessor :unlock_in
  @@unlock_in = 1.hour

  # Tell when to use the default scope, if one cannot be found from routes.
  mattr_accessor :use_default_scope
  @@use_default_scope

  # The default scope which is used by warden.
  mattr_accessor :default_scope
  @@default_scope = nil

  # Address which sends Devise e-mails.
  mattr_accessor :mailer_sender
  @@mailer_sender

  # Authentication token params key name of choice. E.g. /users/sign_in?some_key=...
  mattr_accessor :token_authentication_key
  @@token_authentication_key = :auth_token

  # The realm used in Http Basic Authentication
  mattr_accessor :http_authentication_realm
  @@http_authentication_realm = "Application"

  class << self
    # Default way to setup Devise. Run script/generate devise_install to create
    # a fresh initializer with all configuration values.
    def setup
      yield self
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
    def warden(&block)
      @warden_config = block
    end

    # Configure default url options to be used within Devise and ActionController.
    def default_url_options(&block)
      Devise::Mapping.metaclass.send :define_method, :default_url_options, &block
    end

    # A method used internally to setup warden manager from the Rails initialize
    # block.
    def configure_warden(config) #:nodoc:
      config.default_strategies *Devise::STRATEGIES
      config.failure_app = Devise::FailureApp
      config.silence_missing_strategies!
      config.default_scope = Devise.default_scope

      # If the user provided a warden hook, call it now.
      @warden_config.try :call, config
    end

    # The class of the configured ORM
    def orm_class
      Devise::Orm.const_get(@@orm.to_s.camelize.to_sym)
    end

    # Generate a friendly string randomically to be used as token.
    def friendly_token
      ActiveSupport::SecureRandom.base64(15).tr('+/=', '-_ ').strip.delete("\n")
    end

    # Make Devise aware of an 3rd party Devise-module. For convenience.
    #
    # == Options:
    #
    #   +strategy+    - Boolean value representing if this module got a custom *strategy*.
    #                   Default is +false+. Note: Devise will auto-detect this in such case if this is true.
    #   +model+       - String representing a load path to a custom *model* for this module (to autoload).
    #                   Default is +nil+ (i.e. +false+).
    #   +controller+  - Symbol representing a name of an exisiting or custom *controller* for this module.
    #                   Default is +nil+ (i.e. +false+).
    #
    # == Examples:
    #
    #   Devise.add_module(:party_module)
    #   Devise.add_module(:party_module, :strategy => true, :controller => :sessions)
    #   Devise.add_module(:party_module, :model => 'party_module/model')
    #
    def add_module(module_name, options = {})
      Devise::ALL.unshift module_name        unless Devise::ALL.include?(module_name)
      Devise::STRATEGIES.unshift module_name if options[:strategy] && !Devise::STRATEGIES.include?(module_name)

      if options[:controller]
        controller = options[:controller].to_sym
        Devise::CONTROLLERS[controller] ||= []
        Devise::CONTROLLERS[controller].unshift module_name unless Devise::CONTROLLERS[controller].include?(module_name)
      end

      if options[:model]
        Devise::Models.module_eval do
          autoload :"#{module_name.to_s.classify}", options[:model]
        end
      end

      Devise::Mapping.register module_name
    end
  end
end

begin
  require 'warden'
rescue
  gem 'warden'
  require 'warden'
end

require 'devise/mapping'
require 'devise/rails'
