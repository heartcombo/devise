module Devise
  class PathChecker
    include Rails.application.routes.url_helpers
    
    def initialize(env, scope)
      @env, @scope = env, scope
    end

    def signing_out?
      @env["PATH_INFO"] == send("destroy_#{@scope}_session_path")
    end
  end
end
