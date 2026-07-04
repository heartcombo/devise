# frozen_string_literal: true

class Devise::MagicLinksController < DeviseController
  prepend_before_action :require_no_authentication
  prepend_before_action :allow_params_authentication!, only: :show
  # Authenticate through #show only if coming from a magic link email
  append_before_action :assert_magic_link_token_passed, only: :show

  # GET /resource/magic_link/new
  def new
    self.resource = resource_class.new
  end

  # POST /resource/magic_link
  def create
    self.resource = resource_class.send_magic_link_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_magic_link_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  # GET /resource/magic_link?magic_link_token=abcdef
  def show
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with_navigational(resource) { redirect_to after_sign_in_path_for(resource) }
  end

  protected

    # The path used after sending magic link instructions.
    def after_sending_magic_link_instructions_path_for(resource_name)
      new_session_path(resource_name) if is_navigational_format?
    end

    # Check if a magic_link_token is provided in the request.
    def assert_magic_link_token_passed
      if params[:magic_link_token].blank?
        set_flash_message(:alert, :no_token)
        redirect_to new_session_path(resource_name)
      end
    end

    def auth_options
      { scope: resource_name, recall: "#{controller_path}#new", locale: I18n.locale }
    end

    def translation_scope
      'devise.magic_links'
    end
end
