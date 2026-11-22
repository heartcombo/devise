# frozen_string_literal: true

module Devise
  module Orm # :nodoc:
    def self.active_record?(model)
      defined?(ActiveRecord) && model < ActiveRecord::Base
    end

    def self.dynamoid?(model)
      defined?(::Dynamoid::Document) && model.include?(::Dynamoid::Document)
    end

    def self.aws_record?(model)
      defined?(::Aws::Record) && model.include?(::Aws::Record)
    end

    # Both supported DynamoDB libraries (Dynamoid and aws-record).
    def self.dynamodb?(model)
      dynamoid?(model) || aws_record?(model)
    end

    def self.included(model)
      if Devise::Orm.active_record?(model)
        model.include DirtyTrackingActiveRecordMethods
      elsif Devise::Orm.dynamoid?(model)
        require 'devise/orm/dynamodb/dynamoid_model'
        model.include Devise::Orm::Dynamodb::DynamoidModel
      elsif Devise::Orm.aws_record?(model)
        require 'devise/orm/dynamodb/aws_record_model'
        model.include Devise::Orm::Dynamodb::AwsRecordModel
      else
        model.include DirtyTrackingMongoidMethods
      end
    end

    module DirtyTrackingActiveRecordMethods
      def devise_email_before_last_save
        email_before_last_save
      end

      def devise_email_in_database
        email_in_database
      end

      def devise_saved_change_to_email?
        saved_change_to_email?
      end

      def devise_saved_change_to_encrypted_password?
        saved_change_to_encrypted_password?
      end

      def devise_will_save_change_to_email?
        will_save_change_to_email?
      end

      def devise_unconfirmed_email_will_change!
        unconfirmed_email_will_change!
      end

      def devise_respond_to_and_will_save_change_to_attribute?(attribute)
        respond_to?("will_save_change_to_#{attribute}?") && send("will_save_change_to_#{attribute}?")
      end
    end

    module DirtyTrackingMongoidMethods
      def devise_email_before_last_save
        respond_to?(:email_previously_was) ? email_previously_was : email_was
      end

      def devise_email_in_database
        email_was
      end

      def devise_saved_change_to_email?
        respond_to?(:email_previously_changed?) ? email_previously_changed? : email_changed?
      end

      def devise_saved_change_to_encrypted_password?
        respond_to?(:encrypted_password_previously_changed?) ? encrypted_password_previously_changed? : encrypted_password_changed?
      end

      def devise_will_save_change_to_email?
        email_changed?
      end

      def devise_unconfirmed_email_will_change!
        # Mongoid's will_change! doesn't force unchanged attributes into updates,
        # so we override changed_attributes to make it see a difference.
        unconfirmed_email_will_change!
        changed_attributes["unconfirmed_email"] = nil
      end

      def devise_respond_to_and_will_save_change_to_attribute?(attribute)
        respond_to?("#{attribute}_changed?") && send("#{attribute}_changed?")
      end
    end

    # Shared by the Dynamoid and aws-record integrations. Each of them exposes
    # an ActiveModel-like dirty API (`<attr>_changed?`, `<attr>_was`,
    # `<attr>_will_change!`) plus `devise_saved_changes`, which returns the
    # changes persisted by the last save and is already available inside
    # after_* callbacks (just like ActiveRecord's `saved_changes`).
    module DirtyTrackingDynamodbMethods
      def devise_email_before_last_save
        saved = devise_saved_changes
        saved.key?("email") ? saved["email"].first : email
      end

      def devise_email_in_database
        email_was
      end

      def devise_saved_change_to_email?
        devise_saved_changes.key?("email")
      end

      def devise_saved_change_to_encrypted_password?
        devise_saved_changes.key?("encrypted_password")
      end

      def devise_will_save_change_to_email?
        email_changed?
      end

      def devise_unconfirmed_email_will_change!
        # Marks the attribute as dirty even when its value is unchanged, so it
        # is always written by the next save (see #5783).
        unconfirmed_email_will_change!
      end

      def devise_respond_to_and_will_save_change_to_attribute?(attribute)
        respond_to?("#{attribute}_changed?") && send("#{attribute}_changed?")
      end
    end
  end
end
