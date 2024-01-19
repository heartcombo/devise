# frozen_string_literal: true

module Devise
  class SecretKeyFinder
    def initialize(application)
      @application = application
    end

    def find
      @application.secret_key_base
    end

    private

    def key_exists?(object)
      object.secret_key_base.present?
    end
  end
end
