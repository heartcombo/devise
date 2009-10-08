class Notifier < ::ActionMailer::Base
  cattr_accessor :sender

  def confirmation_instructions(record)
    from         self.class.sender
    recipients   record.email
    subject      I18n.t(:confirmation_instructions, :scope => [:devise, :notifier], :default => 'Confirmation instructions')
    sent_on      Time.now
    content_type 'text/html'
    body         record.class.name.downcase.to_sym => record
  end

  def reset_password_instructions(record)
    from         self.class.sender
    recipients   record.email
    subject      I18n.t(:reset_password_instructions, :scope => [:devise, :notifier], :default => 'Reset password instructions')
    sent_on      Time.now
    content_type 'text/html'
    body         record.class.name.downcase.to_sym => record
  end
end
