class Devise::UnlocksController < DeviseController
  prepend_before_filter :require_no_authentication

  # GET /resource/unlock/new
  def new
    self.resource = resource_class.new
  end

  # POST /resource/unlock
  def create
    self.resource = resource_class.send_unlock_instructions(resource_params)
    after_unlock_instructions_sent(resource)

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_unlock_instructions_path_for(resource))
    else
      respond_with(resource)
    end
  end

  # GET /resource/unlock?unlock_token=abcdef
  def show
    self.resource = resource_class.unlock_access_by_token(params[:unlock_token])

    if resource.errors.empty?
      after_unlock_success(resource)
      set_flash_message :notice, :unlocked if is_flashing_format?
      respond_with_navigational(resource){ redirect_to after_unlock_path_for(resource) }
    else
      after_unlock_fails(resource)
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end

  protected

    # The path used after sending unlock password instructions
    def after_sending_unlock_instructions_path_for(resource)
      new_session_path(resource) if is_navigational_format?
    end

    # The path used after unlocking the resource
    def after_unlock_path_for(resource)
      new_session_path(resource)  if is_navigational_format?
    end

    # Method excecuted after unlock email sent.
    def after_unlock_instructions_sent(resource); end

    # Method excecuted after unlocked using confirmation token.
    def after_unlock_success(resource); end

    # Method excecuted after not unlocked using confirmation token.
    def after_unlock_fails(resource); end

end
