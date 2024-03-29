# frozen_string_literal: true

class UsersController < ApplicationController
  prepend_before_action :current_user, only: :exhibit
  before_action :authenticate_user!, except: [:accept, :exhibit]
  clear_respond_to
  respond_to :html, :json

  def index
    user_session[:cart] = "Cart"
    respond_with(current_user)
  end

  def edit_form
    user_session['last_request_at'] = params.fetch(:last_request_at, 31.minutes.ago.utc)
  end

  def update_form
    render body: 'Update'
  end

  def accept
    @current_user = current_user
  end

  def exhibit
    render body: current_user ? "User is authenticated" : "User is not authenticated"
  end

  def expire
    user_session['last_request_at'] = 31.minutes.ago.utc
    render body: 'User will be expired on next request'
  end
end
