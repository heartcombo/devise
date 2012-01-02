module Devise
  class PathChecker
    include Rails.application.routes.url_helpers

    def self.default_url_options(*args)
      if defined?(ApplicationController)
        ApplicationController.default_url_options(*args)
      else
        {}
      end
    end

    def initialize(env, scope)
      @current_path = "/#{env["SCRIPT_NAME"]}/#{env["PATH_INFO"]}".squeeze("/")
      @scope = scope
    end

    def signing_out?
      route = "destroy_#{@scope}_session_path"
      respond_to?(route) && @current_path == send(route)
    end
  end
end
