class Users::FromProcMailer < Devise::Mailer
  default from: proc { 'custom@example.com' }
end
