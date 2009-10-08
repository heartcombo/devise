module DeviseHelper

  def link_to_sign_in
    link_to 'Sign in', new_session_path
  end

  def link_to_new_password
    link_to 'Forgot password?', new_password_path
  end

  def link_to_new_confirmation
    link_to 'Didn\'t receive confirmation instructions?', new_confirmation_path
  end
end
