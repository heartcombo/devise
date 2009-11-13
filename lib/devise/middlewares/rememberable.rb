module Devise
  module Middlewares
    class Rememberable
      def initialize(app)
        @app = app
      end

      def call(env)
        auth = env['warden']
        scopes = select_cookies(auth.request)
        scopes.each do |scope, token|
          mapping = Devise.mappings[scope]
          next unless mapping && mapping.for.include?(:rememberable)
          user = mapping.to.serialize_from_cookie(token)
          auth.set_user(user, :scope => scope) if user
        end

        @app.call(env)
      end

      protected

        def select_cookies(request)
          scopes = {}
          matching = /remember_(#{Devise.mappings.keys.join("|")})_token/
          request.cookies.each do |key, value|
            if key.to_s =~ matching
              scopes[$1.to_sym] = value
            end
          end
          scopes
        end
    end
  end
end
