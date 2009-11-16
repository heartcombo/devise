module Devise
  module FailureApp
    mattr_accessor :default_url

    # Failure application that will be called every time :warden is thrown from
    # any strategy or hook. Responsible for redirect the user to the sign in
    # page based on current scope and mapping. If no scope is given, redirect
    # to the default_url.
    def self.call(env)
      options = env['warden.options']
      scope   = options[:scope]
      message = env['warden'].try(:message) || options[:message]

      params  = case message
        when Symbol
          { message => true }
        when String
          { :message => message }
        else
          {}
      end

      redirect_path = if mapping = Devise.mappings[scope]
        "#{mapping.parsed_path}/#{mapping.path_names[:sign_in]}"
      else
        "/#{default_url}"
      end
      query_string = Rack::Utils.build_query(params)

      headers = {}
      headers["Location"] = redirect_path
      headers["Location"] << "?" << query_string unless query_string.empty?
      headers["Content-Type"] = 'text/plain'

      [302, headers, ["You are being redirected to #{redirect_path}"]]
    end
  end
end
