class HomeController < ApplicationController
  def index
  end

  def private
  end

  def user_dashboard
  end

  def admin_dashboard
  end

  def join
  end

  def set
    session["devise.foo_bar"] = "something"
    head :ok
  end

  def unauthenticated
    render :text => "unauthenticated", :status => :unauthorized
  end
end
