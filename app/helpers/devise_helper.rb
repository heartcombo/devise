module DeviseHelper

  def link_to_sign_in
    link_to I18n.t(:sign_in, :scope => [:devise, :links], :default => 'Sign in'), new_session_path
  end

  def link_to_new_password
    link_to I18n.t(:new_password, :scope => [:devise, :links], :default => 'Forgot password?'), new_password_path
  end

  def link_to_new_confirmation
    link_to I18n.t(:new_confirmation, :scope => [:devise, :links], :default => 'Didn\'t receive confirmation instructions?'), new_confirmation_path
  end
end
