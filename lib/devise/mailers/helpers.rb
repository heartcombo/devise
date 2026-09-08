# frozen_string_literal: true

module Devise
  module Mailers
    module Helpers
      extend ActiveSupport::Concern

      included do
        include Devise::Controllers::ScopedViews
      end

      protected

      attr_reader :scope_name, :resource

      # Configure default email options
      def devise_mail(record, action, opts = {}, &block)
        initialize_from_record(record)
        mail headers_for(action, opts), &block
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

        # Tell the recipient's software when the message stops being useful
        expiry = expires_at_for(action)
        headers[:Expires] = expiry.rfc2822 if expiry

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

      def expires_at_for(action)
        case action
        when :reset_password_instructions
          expires_at(resource.reset_password_sent_at, resource.class.reset_password_within)
        when :confirmation_instructions
          # Note: allow_unconfirmed_access_for would be wrong here.
          expires_at(resource.confirmation_sent_at, resource.class.confirm_within)
        end
      end

      def expires_at(sent_at, within)
        sent_at + within if sent_at && within
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
    end
  end
end
