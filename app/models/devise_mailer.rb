class DeviseMailer < ::ActionMailer::Base
  extend Devise::Controllers::InternalHelpers::ScopedViews

  # Deliver confirmation instructions when the user is created or its email is
  # updated, and also when confirmation is manually requested
  def confirmation_instructions(record)
    setup_mail(record, :confirmation_instructions)
  end

  # Deliver reset password instructions when manually requested
  def reset_password_instructions(record)
    setup_mail(record, :reset_password_instructions)
  end

  def unlock_instructions(record)
    setup_mail(record, :unlock_instructions)
  end

  private

    # Configure default email options
    def setup_mail(record, key)
      mapping = Devise::Mapping.find_by_class(record.class)
      raise "Invalid devise resource #{record}" unless mapping

      subject      translate(mapping, key)
      from         mailer_sender(mapping)
      recipients   record.email
      sent_on      Time.now
      content_type 'text/html'
      body         render_with_scope(key, mapping, mapping.name => record, :resource => record)
    end

    def render_with_scope(key, mapping, assigns)
      if self.class.scoped_views
        begin
          render :file => "devise_mailer/#{mapping.as}/#{key}", :body => assigns
        rescue ActionView::MissingTemplate
          render :file => "devise_mailer/#{key}", :body => assigns
        end
      else
        render :file => "devise_mailer/#{key}", :body => assigns
      end
    end

    def mailer_sender(mapping)
      if Devise.mailer_sender.is_a?(Proc)
        block_args = mapping.name if Devise.mailer_sender.arity > 0
        Devise.mailer_sender.call(block_args)
      else
        Devise.mailer_sender
      end
    end

    # Setup subject namespaced by model. It means you're able to setup your
    # messages using specific resource scope, or provide a default one.
    # Example (i18n locale file):
    #
    #   en:
    #     devise:
    #       mailer:
    #         confirmation_instructions: '...'
    #         user:
    #           confirmation_instructions: '...'
    def translate(mapping, key)
      I18n.t(:"#{mapping.name}.#{key}", :scope => [:devise, :mailer], :default => key)
    end
end
