class ConfirmationsController < ApplicationController
  before_filter :find_resource_class

  # GET /confirmation/new
  #
  def new
  end

  # POST /confirmation
  #
  def create
    self.resource = resource_class.send_confirmation_instructions(params[resource_name])
    if resource.errors.empty?
      flash[:success] = I18n.t(:send_instructions, :scope => [:devise, :confirmations], :default => 'You will receive an email with instructions about how to confirm your account in a few minutes.')
      redirect_to new_session_path(resource_name)
    else
      render :new
    end
  end

  # GET /confirmation?perishable_token=abcdef
  #
  def show
    self.resource = resource_class.confirm!(:perishable_token => params[:perishable_token])
    if resource.errors.empty?
      flash[:success] = I18n.t(:confirm, :scope => [:devise, :confirmations], :default => 'Your account was successfully confirmed!')
      redirect_to new_session_path(resource_name)
    else
      render :new
    end
  end
end
