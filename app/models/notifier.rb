class Notifier < ::ActionMailer::Base
  cattr_accessor :sender

  # Deliver confirmation instructions when the user is created or its email is
  # updated, and also when confirmation is manually requested
  def confirmation_instructions(record)
    setup_mail(record, :confirmation_instructions)
  end

  # Deliver reset password instructions when manually requested
  def reset_password_instructions(record)
    setup_mail(record, :reset_password_instructions)
  end

  private

    # Configure default email options
    def setup_mail(record, key)
      subject      translate(record, key)
      from         self.class.sender
      recipients   record.email
      sent_on      Time.now
      content_type 'text/html'
      body         record.class.name.downcase.to_sym => record, :resource => record
    end

    # Setup subject namespaced by model. It means you're able to setup your
    # messages using specific resource scope, or provide a default one.
    # Example (i18n locale file):
    #
    #   en:
    #     devise:
    #       notifier:
    #         confirmation_instructions: '...'
    #       user:
    #         notifier:
    #           confirmation_instructions: '...'
    def translate(record, key)
      I18n.t(:"#{record.class.name.downcase}.#{key}",
             :scope => [:devise, :notifier],
             :default => key)
    end
end
