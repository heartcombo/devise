class SessionsController < Devise::SessionsController
  def new
    flash[:notice] = "Welcome to #{controller_path.inspect} controller!"
    super
  end
end