module Devise
  autoload :FailureApp, 'devise/failure_app'
  autoload :Mapping, 'devise/mapping'
  autoload :Schema, 'devise/schema'
  autoload :TestHelpers, 'devise/test_helpers'

  module Controllers
    autoload :Filters, 'devise/controllers/filters'
    autoload :Helpers, 'devise/controllers/helpers'
    autoload :UrlHelpers, 'devise/controllers/url_helpers'
  end

  module Encryptors
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

  ALL = [:authenticatable, :confirmable, :recoverable, :rememberable,
         :timeoutable, :trackable, :validatable]

  # Maps controller names to devise modules
  CONTROLLERS = {
    :sessions => [:authenticatable],
    :passwords => [:recoverable],
    :confirmations => [:confirmable]
  }

  STRATEGIES  = [:authenticatable]
  SERIALIZERS = [:authenticatable, :rememberable]
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE']

  # Maps the messages types that are used in flash message. This array is not
  # frozen, so you can add messages from your own strategies.
  FLASH_MESSAGES = [ :unauthenticated, :unconfirmed, :invalid, :timeout ]

  # Declare encryptors length which are used in migrations.
  ENCRYPTORS_LENGTH = {
    :sha1   => 40,
    :sha512 => 128,
    :clearance_sha1 => 40,
    :restful_authentication_sha1 => 40,
    :authlogic_sha512 => 128
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
  @@mappings = {}

  # Stores the chosen ORM.
  mattr_accessor :orm
  @@orm = :active_record

  # Configure default options used in :all.
  mattr_accessor :all
  @@all = Devise::ALL.dup

  # Tells if devise should apply the schema in ORMs where devise declaration
  # and schema belongs to the same class (as Datamapper and MongoMapper).
  mattr_accessor :apply_schema
  @@apply_schema = true

  # Scoped views. Since it relies on fallbacks to render default views, it's
  # turned off by default.
  mattr_accessor :scoped_views
  @@scoped_views = false

  class << self
    # Default way to setup Devise. Run script/generate devise_install to create
    # a fresh initializer with all configuration values.
    def setup
      yield self
    end

    # Sets the sender in DeviseMailer.
    def mailer_sender=(value)
      DeviseMailer.sender = value
    end
    alias :sender= :mailer_sender=

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
    def configure_warden_manager(manager) #:nodoc:
      manager.default_strategies *Devise::STRATEGIES
      manager.default_serializers *Devise::SERIALIZERS
      manager.failure_app = Devise::FailureApp
      manager.silence_missing_strategies!
      manager.silence_missing_serializers!

      # If the user provided a warden hook, call it now.
      @warden_config.try :call, manager
    end

    # The class of the configured ORM
    def orm_class
      Devise::Orm.const_get(@@orm.to_s.camelize.to_sym)
    end

    # Generate a friendly string randomically to be used as token.
    def friendly_token
      ActiveSupport::SecureRandom.base64(15).tr('+/=', '-_ ').strip.delete("\n")
    end
  end
end

begin
  require 'warden'
rescue
  gem 'warden'
  require 'warden'
end

# Set the default_scope to nil, so it's overwritten when the first route is declared.
Warden::Manager.default_scope = nil
require 'devise/rails'
