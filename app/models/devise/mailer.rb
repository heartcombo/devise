class Devise::Mailer < ::ActionMailer::Base
  include Devise::Controllers::ScopedViews

  attr_reader :devise_mapping, :resource

  def confirmation_instructions(record)
    setup_mail(record, :confirmation_instructions)
  end

  def reset_password_instructions(record)
    setup_mail(record, :reset_password_instructions)
  end

  def unlock_instructions(record)
    setup_mail(record, :unlock_instructions)
  end

  private

    # Configure default email options
    def setup_mail(record, action)
      @devise_mapping = Devise::Mapping.find_by_class(record.class)

      raise "Invalid devise resource #{record}" unless @devise_mapping
      @resource = instance_variable_set("@#{@devise_mapping.name}", record)

      mail(:subject => translate(@devise_mapping, action),
           :from => mailer_sender(@devise_mapping), :to => record.email) do |format|
        format.html { render_with_scope(action, :controller => "mailer") }
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
