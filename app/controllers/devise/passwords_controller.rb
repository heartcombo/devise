class Devise::PasswordsController < ApplicationController
  prepend_before_filter :require_no_authentication, :only => [:new, :create]
  include Devise::Controllers::InternalHelpers

  # GET /resource/password/new
  def new
    build_resource({})
    render_with_scope :new
  end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions
      redirect_to new_session_path(resource_name)
    else
      render_with_scope :new
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    render_with_scope :edit
  end
  
  # PUT /resource/password
  def update    
    self.resource = signed_in_resource
    
    unless resource.nil?
      resource.reset_password!(params[resource_name][:password], params[resource_name][:password_confirmation])
    else    
      self.resource = resource_class.reset_password_by_token(params[resource_name])
    end

    if resource.errors.empty?
      set_flash_message :notice, :updated
      if user_signed_in?
        sign_out(resource)
      end
      
      sign_in_and_redirect(resource_name, resource)
    else
      render_with_scope :edit
    end
  end
end
