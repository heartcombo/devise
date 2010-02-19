require "action_controller/metal"

module Devise
  # Failure application that will be called every time :warden is thrown from
  # any strategy or hook. Responsible for redirect the user to the sign in
  # page based on current scope and mapping. If no scope is given, redirect
  # to the default_url.
  class FailureApp < ActionController::Metal
    include ActionController::RackDelegation
    include ActionController::UrlFor
    include ActionController::Redirecting

    mattr_accessor :default_message
    self.default_message = :unauthenticated

    def self.call(env)
      action(:respond).call(env)
    end

    def self.default_url_options(*args)
      ApplicationController.default_url_options(*args)
    end

    def respond
      scope = warden_options[:scope]
      store_location!(scope)
      redirect_to send(:"new_#{scope}_session_path", query_string_params)
    end

  protected

    # Build the proper query string based on the given message.
    def query_string_params
      message = warden.try(:message) || warden_options[:message] || self.class.default_message

      case message
      when Symbol
        { message => true }
      when String
        { :message => message }
      else
        {}
      end
    end

    def warden
      env['warden']
    end

    def warden_options
      env['warden.options']
    end

    # Stores requested uri to redirect the user after signing in. We cannot use
    # scoped session provided by warden here, since the user is not authenticated
    # yet, but we still need to store the uri based on scope, so different scopes
    # would never use the same uri to redirect.
    def store_location!(scope)
      session[:"#{scope}.return_to"] = request.request_uri if request && request.get?
    end
  end
end
