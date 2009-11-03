module Devise
  ALL = [:authenticatable, :confirmable, :recoverable, :rememberable, :validatable].freeze

  # Maps controller names to devise modules
  CONTROLLERS = {
    :sessions => :authenticatable,
    :passwords => :recoverable,
    :confirmations => :confirmable
  }.freeze

  STRATEGIES  = [:rememberable, :authenticatable].freeze
  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE'].freeze

  class << self
    # Default way to setup Devise. Run script/generate devise_install to create
    # a fresh initializer with all configuration values.
    def setup
      yield self
    end

    # Sets the sender in DeviseMailer.
    def mail_sender=(value)
      DeviseMailer.sender = value
    end
    alias :sender= :mail_sender= 

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

    # A method used internally to setup warden manager from the Rails initialize
    # block.
    def configure_warden_manager(manager) #:nodoc:
      manager.default_strategies *Devise::STRATEGIES
      manager.failure_app = Devise::Failure
      manager.silence_missing_strategies!

      # If the user provided a warden hook, call it now.
      @warden_config.try :call, manager
    end
  end
end

require 'devise/warden'
require 'devise/mapping'
require 'devise/rails'
