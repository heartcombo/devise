module Devise
  ALL = [:authenticatable, :confirmable, :recoverable, :rememberable, :validatable].freeze

  # Maps controller names to devise modules
  CONTROLLERS = {
    :sessions => :authenticatable,
    :passwords => :recoverable,
    :confirmations => :confirmable
  }.freeze

  STRATEGIES  = [:authenticatable].freeze
  SERIALIZERS = [:authenticatable, :rememberable].freeze
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].freeze

  # Maps the messages types that comes from warden to a flash type.
  # This hash is not frozen, so you can add your messages as well.
  FLASH_MESSAGES = {
    :unauthenticated => :success,
    :unconfirmed => :failure
  }

  # Declare encryptors length which are used in migrations.
  ENCRYPTORS_LENGTH = {
    :sha1   => 40,
    :sha512 => 128,
    :clearance_sha1 => 40,
    :restful_authentication_sha1 => 40,
    :authlogic_sha512 => 128
  }

  # Used to encrypt password. Please generate one with rake secret
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

  # Used to define the password encryption algorithm.
  def self.encryptor=(value)
    @@encryptor = if value.is_a?(Symbol)
      ::Devise::Encryptors.const_get(value.to_s.classify)
    else
      value
    end
  end
  mattr_reader :encryptor
  @@encryptor = ::Devise::Encryptors::Sha1

  # Store scopes mappings.
  mattr_accessor :mappings
  @@mappings = {}

  # Stores the chosen ORM.
  mattr_accessor :orm
  @@orm = :active_record

  class << self
    # Default way to setup Devise. Run script/generate devise_install to create
    # a fresh initializer with all configuration values.
    def setup
      yield self
    end

    def mail_sender=(value) #:nodoc:
      ActiveSupport::Deprecation.warn "Devise.mail_sender= is deprecated, use Devise.mailer_sender instead"
      DeviseMailer.sender = value
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
      manager.failure_app = Devise::Failure
      manager.silence_missing_strategies!
      manager.silence_missing_serializers!

      # If the user provided a warden hook, call it now.
      @warden_config.try :call, manager
    end

    # The class of the configured ORM
    def orm_class
      Devise::Orm.const_get(@@orm.to_s.camelize.to_sym)
    end
  end
end

begin
  require 'warden'
rescue
  gem 'warden'
  require 'warden'
end

require 'devise/strategies/base'
require 'devise/serializers/base'

require 'devise/rails'