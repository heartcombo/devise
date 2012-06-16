class AdminsController < ApplicationController
  before_filter :authenticate_admin!

  def index
  end

  def expire
    admin_session['last_request_at'] = 31.minutes.ago.utc
    render :text => 'Admin will be expired on next request'
  end
end
