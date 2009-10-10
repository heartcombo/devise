class ConfirmationsController < ApplicationController
  skip_before_filter :authenticate!
  before_filter :require_no_authentication

  # GET /confirmation/new
  #
  def new
  end

  # POST /confirmation
  #
  def create
    @confirmation = resource_class.send_confirmation_instructions(params[:confirmation])
    if @confirmation.errors.empty?
      flash[:notice] = I18n.t(:send_instructions, :scope => [:devise, :confirmations], :default => 'You will receive an email with instructions about how to confirm your account in a few minutes.')
      redirect_to new_session_path
    else
      render :new
    end
  end

  # GET /confirmation?perishable_token=abcdef
  #
  def show
    @confirmation = resource_class.confirm!(:perishable_token => params[:perishable_token])
    if @confirmation.errors.empty?
      flash[:notice] = I18n.t(:confirm, :scope => [:devise, :confirmations], :default => 'Your account was successfully confirmed!')
      redirect_to new_session_path
    else
      render :new
    end
  end
end
