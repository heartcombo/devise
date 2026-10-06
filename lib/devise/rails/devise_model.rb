# frozen_string_literal: true

module Devise
  ALLOWED_DEVISE_MODEL_OPTIONS = [:class_name, :singular, :as].freeze

  # Registers the model phase of a Devise mapping during Rails initialization,
  # before routes are loaded. This makes Devise.mappings[scope] available early
  # (with its model, scope and strategies) even when routes are lazy-loaded,
  # which Rails does by default in development and test starting from Rails 8.
  #
  #   Devise.devise_model :user
  #   Devise.devise_model :admin, class_name: "Account", singular: :manager
  def self.devise_model(resource, options = {})
    options = options.symbolize_keys
    invalid_options = options.keys - ALLOWED_DEVISE_MODEL_OPTIONS

    unless invalid_options.empty?
      raise ArgumentError, "Devise.devise_model only accepts model options " \
        "(#{ALLOWED_DEVISE_MODEL_OPTIONS.join(', ')}); got: #{invalid_options.join(', ')}. " \
        "Routing options must be given to devise_for."
    end

    add_mapping(resource, options)
  end
end
