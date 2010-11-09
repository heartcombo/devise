class HomeController < ApplicationController
  def index
  end

  def private
  end

  def set
    session["devise.foo_bar"] = "something"
    head :ok
  end

  def unauthenticated
    render :text => "unauthenticated", :status => :unauthorized
  end
end
