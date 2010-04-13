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
      @scope_name     = Devise::Mapping.find_scope!(record)
      @devise_mapping = Devise.mappings[@scope_name]
      @resource       = instance_variable_set("@#{@devise_mapping.name}", record)

      template_path = ["devise/mailer"]
      template_path.unshift "#{@devise_mapping.as}/mailer" if self.class.scoped_views?

      headers = {
        :subject => translate(@devise_mapping, action),
        :from => mailer_sender(@devise_mapping),
        :to => record.email,
        :template_path => template_path
      }

      headers.merge!(record.headers_for(action)) if record.respond_to?(:headers_for)
      mail(headers)
    end

    # Fix a bug in Rails 3 beta 3
    def mail(*) #:nodoc:
      super
      @_message["template_path"] = nil
      @_message
    end

    def mailer_sender(mapping)
      if Devise.mailer_sender.is_a?(Proc)
        Devise.mailer_sender.call(mapping.name)
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
