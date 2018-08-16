# frozen_string_literal: true

module Devise
  class SecretKeyFinder
    COMMON_CONFIGURATION_LOCATIONS = [
      'application.secret_key_base',
      'application.credentials.secret_key_base',
      'application.secrets.secret_key_base',
      'application.config.secret_key_base'
    ].freeze

    def initialize(application)
      @application = application
    end

    def find
      return ENV['SECRET_KEY_BASE'] if ENV['SECRET_KEY_BASE']
      COMMON_CONFIGURATION_LOCATIONS.find do |chain|
        if secret_key_base = reduce_methods(chain)
          break secret_key_base
        end
      end
    end

    private

    attr_reader :application

    def reduce_methods(chain)
      begin
        chain.split('.').reduce(self){|obj, msg| obj.send(msg)}
      rescue NoMethodError
        nil
      end
    end
  end
end