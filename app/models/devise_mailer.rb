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

      @resource = instance_variable_set("@#{mapping.name}", record)

      mail(:subject => translate(mapping, key), :from => mailer_sender(mapping),
           :to => record.email) do |format|
        format.html { render_with_scope(key, mapping) }
      end
    end

    def render_with_scope(key, mapping)
      if self.class.scoped_views
        begin
          render :template => "devise_mailer/#{mapping.as}/#{key}"
        rescue ActionView::MissingTemplate
          render :template => "devise_mailer/#{key}"
        end
      else
        render :template => "devise_mailer/#{key}"
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
