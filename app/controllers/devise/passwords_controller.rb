class Devise::PasswordsController < ApplicationController
  prepend_before_filter :require_no_authentication
  include Devise::Controllers::InternalHelpers

  respond_to :html, :xml, :json

  # GET /resource/password/new
  def new
    build_resource({})
    render_with_scope :new
  end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message(:notice, :send_instructions) if is_navigational_format?
      respond_with self.resource, :location => new_session_path(resource_name)
    else
      respond_to do |format|
        format.html { render_with_scope :new }
        format.any(:xml, :json) { render request.format.to_sym => { :errors => self.resource.errors }, :status => :unprocessable_entity }
      end
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
    self.resource = resource_class.reset_password_by_token(params[resource_name])

    if resource.errors.empty?
      set_flash_message(:notice, :updated) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => redirect_location(resource_name, resource)
    else
      respond_to do |format|
        format.html { render_with_scope :edit }
        format.any(:xml, :json) { render request.format.to_sym => { :errors => self.resource.errors }, :status => :unprocessable_entity }
      end
    end
  end
end
