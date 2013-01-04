class Devise::Mailer < ::ActionMailer::Base
  include Devise::Mailers::Helpers

  def confirmation_instructions(record, opts={})
    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, opts={})
    devise_mail(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record, opts={})
    devise_mail(record, :unlock_instructions, opts)
  end
end
