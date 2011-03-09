module Devise
  # Failure application that will be called every time :warden is thrown from
  # any strategy or hook. Responsible for redirect the user to the sign in
  # page based on current scope and mapping. If no scope is given, redirect
  # to the default_url.
  class FailureApp
    attr_reader :env
    include Warden::Mixins::Common

    cattr_accessor :default_url, :default_message, :instance_writer => false
    @@default_message = :unauthenticated

    def self.call(env)
      new(env).respond!
    end

    def initialize(env)
      @env = env
    end

    def respond!
      options = @env['warden.options']
      scope   = options[:scope]

      redirect_path = redirect_path_for(scope)
      query_string  = query_string_for(options)
      store_location!(scope)

      headers = {}
      headers["Location"] = redirect_path
      headers["Location"] << "?" << query_string unless query_string.empty?
      headers["Content-Type"] = 'text/plain'

      [302, headers, ["You are being redirected to #{redirect_path}"]]
    end

    # Build the proper query string based on the given message.
    def query_string_for(options)
      message = @env['warden'].try(:message) || options[:message] || default_message

      params = case message
        when Symbol
          { message => true }
        when String
          { :message => message }
        else
          {}
      end

      Rack::Utils.build_query(params)
    end

    # Build the path based on current scope.
    def redirect_path_for(scope)
      if mapping = Devise.mappings[scope]
        "#{mapping.parsed_path}/#{mapping.path_names[:sign_in]}"
      else
        "/#{default_url}"
      end
    end

    # Stores requested uri to redirect the user after signing in. We cannot use
    # scoped session provided by warden here, since the user is not authenticated
    # yet, but we still need to store the uri based on scope, so different scopes
    # would never use the same uri to redirect.
    def store_location!(scope)
      if request && request.get? && !request.xhr?
        session[:"#{scope}.return_to"] = request.request_uri
      end
    end
  end
end
