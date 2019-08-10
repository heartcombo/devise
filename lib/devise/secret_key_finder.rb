# frozen_string_literal: true

module Devise
  class SecretKeyFinder
    def initialize(application)
      @application = application
    end

    def find
      secret_key_base(:credentials) || secret_key_base(:secrets) ||
        secret_key_base(:config) || secret_key_base
    end

    private

    def secret_key_base(source = nil)
      return @application.secret_key_base unless source
      return nil unless @application.respond_to?(source)

      secret_key_base = @application.send(source).secret_key_base
      secret_key_base.present? ? secret_key_base : nil
    end
  end
end
