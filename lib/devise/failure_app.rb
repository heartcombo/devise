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
    include Rails.application.routes.url_helpers
    include Devise::Controllers::SharedHelpers

    delegate :flash, :to => :request

    def self.call(env)
      @respond ||= action(:respond)
      @respond.call(env)
    end

    def self.default_url_options(*args)
      ApplicationController.default_url_options(*args)
    end

    def respond
      if http_auth?
        http_auth
      elsif warden_options[:recall]
        recall
      else
        redirect
      end
    end

    def http_auth
      self.status = 401
      self.headers["WWW-Authenticate"] = %(Basic realm=#{Devise.http_authentication_realm.inspect}) if http_auth_header?
      self.content_type = request.format.to_s
      self.response_body = http_auth_body
    end

    def recall
      env["PATH_INFO"]  = attempted_path
      flash.now[:alert] = i18n_message(:invalid)
      self.response = recall_app(warden_options[:recall]).call(env)
    end

    def redirect
      store_location!
      flash[:alert] = i18n_message
      redirect_to redirect_url
    end

  protected

    def i18n_message(default = nil)
      message = warden.message || warden_options[:message] || default || :unauthenticated

      if message.is_a?(Symbol)
        I18n.t(:"#{scope}.#{message}", :resource_name => scope,
               :scope => "devise.failure", :default => [message, message.to_s])
      else
        message.to_s
      end
    end

    def redirect_url
      opts  = {}
      route = :"new_#{scope}_session_path"
      opts[:format] = request_format unless skip_format?

      if respond_to?(route)
        send(route, opts)
      else
        root_path(opts)
      end
    end

    def skip_format?
      %w(html */*).include? request_format.to_s
    end

    # Choose whether we should respond in a http authentication fashion,
    # including 401 and optional headers.
    #
    # This method allows the user to explicitly disable http authentication
    # on ajax requests in case they want to redirect on failures instead of
    # handling the errors on their own. This is useful in case your ajax API
    # is the same as your public API and uses a format like JSON (so you
    # cannot mark JSON as a navigational format).
    def http_auth?
      if request.xhr?
        Devise.http_authenticatable_on_xhr
      else
        !(request_format && is_navigational_format?)
      end
    end

    # It does not make sense to send authenticate headers in ajax requests
    # or if the user disabled them.
    def http_auth_header?
      Devise.mappings[scope].to.http_authenticatable && !request.xhr?
    end

    def http_auth_body
      return i18n_message unless request_format
      method = "to_#{request_format}"
      if method == "to_xml"
        { :error => i18n_message }.to_xml(:root => "errors")
      elsif {}.respond_to?(method)
        { :error => i18n_message }.send(method)
      else
        i18n_message
      end
    end

    def recall_app(app)
      controller, action = app.split("#")
      controller_name  = ActiveSupport::Inflector.camelize(controller)
      controller_klass = ActiveSupport::Inflector.constantize("#{controller_name}Controller")
      controller_klass.action(action)
    end

    def warden
      env['warden']
    end

    def warden_options
      env['warden.options']
    end

    def scope
      @scope ||= warden_options[:scope] || Devise.default_scope
    end

    def attempted_path
      warden_options[:attempted_path]
    end

    # Stores requested uri to redirect the user after signing in. We cannot use
    # scoped session provided by warden here, since the user is not authenticated
    # yet, but we still need to store the uri based on scope, so different scopes
    # would never use the same uri to redirect.
    def store_location!
      session["#{scope}_return_to"] = attempted_path if request.get? && !http_auth?
    end
  end
end
