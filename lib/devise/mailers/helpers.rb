# frozen_string_literal: true

module Devise
  module Mailers
    module Helpers
      extend ActiveSupport::Concern

      MultipleRecipientsError = Class.new(ArgumentError)

      included do
        include Devise::Controllers::ScopedViews
      end

      protected

      attr_reader :scope_name, :resource

      # Configure default email options
      def devise_mail(record, action, opts = {}, &block)
        initialize_from_record(record)

        headers = headers_for(action, opts)
        validate_single_recipient_in_headers!(headers) if Devise.strict_single_recipient_emails.include?(action)

        mail headers, &block
      end

      def initialize_from_record(record)
        @scope_name = Devise::Mapping.find_scope!(record)
        @resource   = instance_variable_set("@#{devise_mapping.name}", record)
      end

      def devise_mapping
        @devise_mapping ||= Devise.mappings[scope_name]
      end

      def headers_for(action, opts)
        headers = {
          subject: subject_for(action),
          to: resource.email,
          from: mailer_sender(devise_mapping),
          reply_to: mailer_sender(devise_mapping),
          template_path: template_paths,
          template_name: action
        }
        # Give priority to the mailer's default if they exists.
        headers.delete(:from) if default_params[:from]
        headers.delete(:reply_to) if default_params[:reply_to]

        headers.merge!(opts)

        @email = headers[:to]
        headers
      end

      def mailer_sender(mapping)
        if Devise.mailer_sender.is_a?(Proc)
          Devise.mailer_sender.call(mapping.name)
        else
          Devise.mailer_sender
        end
      end

      def template_paths
        template_path = _prefixes.dup
        template_path.unshift "#{@devise_mapping.scoped_path}/mailer" if self.class.scoped_views?
        template_path
      end

      # Set up a subject doing an I18n lookup. At first, it attempts to set a subject
      # based on the current mapping:
      #
      #   en:
      #     devise:
      #       mailer:
      #         confirmation_instructions:
      #           user_subject: '...'
      #
      # If one does not exist, it fallbacks to ActionMailer default:
      #
      #   en:
      #     devise:
      #       mailer:
      #         confirmation_instructions:
      #           subject: '...'
      #
      def subject_for(key)
        I18n.t(:"#{devise_mapping.name}_subject", scope: [:devise, :mailer, key],
          default: [:subject, key.to_s.humanize])
      end

      # It is possible to send email to one or more recipients in one
      # email by setting a list of emails in the :to key, or by :cc or
      # :bcc-ing recipients.
      # https://guides.rubyonrails.org/action_mailer_basics.html#sending-email-to-multiple-recipients
      #
      # This method ensures the headers contain a single recipient.
      def validate_single_recipient_in_headers!(headers)
        return unless headers

        symbolized_headers = headers.symbolize_keys

        if headers.keys.length != symbolized_headers.keys.length
          raise MultipleRecipientsError, "headers has colliding key names"
        end

        if symbolized_headers[:cc] || symbolized_headers[:bcc]
          raise MultipleRecipientsError, 'headers[:cc] and headers[:bcc] are not allowed'
        end

        if symbolized_headers[:to] && !validate_single_recipient_in_email(symbolized_headers[:to])
          raise MultipleRecipientsError, 'headers[:to] must be a string not containing ; or ,'
        end

        true
      end

      # Returns true if email is a String not containing email
      # separators: commas (RFC5322) or semicolons (RFC1485).
      #
      # Unlike Devise.email_regexp (which can be overridden), it does
      # not validate that the email is valid.
      def validate_single_recipient_in_email(email)
        email.is_a?(String) && !email.match(/[;,]/)
      end

    end
  end
end
