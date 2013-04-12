class Users::Mailer < Devise::Mailer
  default :from     => 'custom@example.com'
end

class Users::ReplyToMailer < Devise::Mailer
  default :from     => 'custom@example.com'
  default :reply_to => 'custom_reply_to@example.com'
end

class Users::FromProcMailer < Devise::Mailer
  default :from     => proc { 'custom@example.com' }
end
