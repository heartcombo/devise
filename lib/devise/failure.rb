module Devise
  module Failure
    mattr_accessor :default_url

    # Failure application that will be called every time :warden is thrown from
    # any strategy or hook. Responsible for redirect the user to the sign in
    # page based on current scope and mapping. If no scope is given, redirect
    # to the default_url.
    def self.call(env)
      options = env['warden.options']
      scope   = options[:scope]
      params  = case env['warden'].try(:message)
        when Symbol
          { env['warden'].message => true }
        when String
          { :message => env['warden'].message }
        else
          options[:params]
      end

      redirect_path = if mapping = Devise.mappings[scope]
        "#{mapping.parsed_path}/#{mapping.path_names[:sign_in]}"
      else
        "/#{default_url}"
      end

      headers = {}
      headers["Location"] = redirect_path
      headers["Location"] << "?" << Rack::Utils.build_query(params) if params
      headers["Content-Type"] = 'text/plain'

      message = options[:message] || "You are being redirected to #{redirect_path}"
      [302, headers, [message]]
    end
  end
end
