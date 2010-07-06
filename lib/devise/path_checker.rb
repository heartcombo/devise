module Devise
  class PathChecker
    include Rails.application.routes.url_helpers

    def initialize(env, scope)
      @current_path = "/#{env["SCRIPT_NAME"]}/#{env["PATH_INFO"]}".squeeze("/")
      @scope = scope
    end

    def signing_out?
      @current_path == send("destroy_#{@scope}_session_path")
    end
  end
end
