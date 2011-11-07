module Devise
  # Checks the scope in the given environment and returns the associated failure app.
  class Delegator
    def call(env)
      failure_app(env).call(env)
    end

    def failure_app(env)
      app = env["warden.options"] &&
        (scope = env["warden.options"][:scope]) &&
        Devise.mappings[scope].failure_app

      app || Devise::FailureApp
    end
  end
end