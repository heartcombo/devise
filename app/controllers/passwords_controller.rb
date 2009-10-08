class PasswordsController < ApplicationController
  before_filter :require_no_authentication

  def new
  end

  def create
    @password = User.send_reset_password_instructions(params[:password])
    if @password.errors.empty?
      flash[:notice] = 'You will receive an email with instructions about how to reset your password in a few minutes.'
      redirect_to new_session_path
    else
      render :new
    end
  end

  def edit
    @password = User.new
    @password.perishable_token = params[:perishable_token]
  end

  def update
    @password = User.reset_password(params[:password])
    if @password.errors.empty?
      flash[:notice] = 'Your password was changed successfully.'
      redirect_to new_session_path
    else
      render :edit
    end
  end
end
