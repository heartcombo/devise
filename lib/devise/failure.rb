module Devise
  module Failure

    # Failure application that will be called every time :warden is thrown from
    # any strategy or hook. Responsible for redirect the user to the sign in
    # page based on current scope and mapping.
    def self.call(env)
      options = env['warden.options']
      params = options[:params] || {}
      scope = options[:scope]
      mapping = Devise.mappings[scope]

      redirect_path = "/#{mapping.as}/#{mapping.path_names[:sign_in]}"

      headers = {}
      headers["Location"] = redirect_path
      headers["Location"] << "?" << Rack::Utils.build_query(params) unless params.empty?
      headers["Content-Type"] = 'text/plain'

      message = options[:message] || "You are being redirected to #{redirect_path}"

      [302, headers, message]
    end
  end
end
