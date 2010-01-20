module Devise
  module Controllers
    # Common actions shared between Devie controllers
    module Common #:nodoc:
      # GET /resource/controller/new
      def new
        build_resource
        render_with_scope :new
      end

      # POST /resource/controller
      def create
        self.resource = resource_class.send(send_instructions_with, params[resource_name])

        if resource.errors.empty?
          set_flash_message :notice, :send_instructions
          redirect_to new_session_path(resource_name)
        else
          render_with_scope :new
        end
      end
    end
  end
end
