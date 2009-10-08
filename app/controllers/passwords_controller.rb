class PasswordsController < ApplicationController
  before_filter :require_no_authentication

  def new
  end

  def create
    @password = User.find_and_send_reset_password_instructions(params[:password][:email])
    if !@password.new_record?
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
    @password = User.find_and_reset_password(params[:password][:perishable_token],
      params[:password][:password], params[:password][:password_confirmation])
    if @password.errors.empty?
      flash[:notice] = 'Your password was changed successfully.'
      redirect_to new_session_path
    else
      render :edit
    end
  end
end
