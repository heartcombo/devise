class ConfirmationsController < ApplicationController
  before_filter :require_no_authentication

  def new
  end

  def create
    @confirmation = User.send_confirmation_instructions(params[:confirmation])
    if @confirmation.errors.empty?
      flash[:notice] = I18n.t(:send_instructions, :scope => [:devise, :confirmation], :default => 'You will receive an email with instructions about how to confirm your account in a few minutes.')
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @confirmation = User.confirm!(:perishable_token => params[:perishable_token])
    if @confirmation.errors.empty?
      flash[:notice] = I18n.t(:confirm, :scope => [:devise, :confirmation], :default => 'Your account was successfully confirmed!')
      redirect_to root_path
    else
      render :new
    end
  end
end
