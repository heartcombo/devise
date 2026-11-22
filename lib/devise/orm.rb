# frozen_string_literal: true

module Devise
  module Orm # :nodoc:
    def self.active_record?(model)
      defined?(ActiveRecord) && model < ActiveRecord::Base
    end

    def self.dynamodb?(model)
      return false unless model.is_a?(Class)

      (defined?(Dynamoid::Document) && model.include?(Dynamoid::Document)) ||
        (defined?(Aws::Record) && model.include?(Aws::Record))
    end

    def self.included(model)
      if Devise::Orm.active_record?(model)
        model.include DirtyTrackingActiveRecordMethods
      elsif Devise::Orm.dynamodb?(model)
        model.include DirtyTrackingDynamodbMethods
      else
        model.include DirtyTrackingMongoidMethods
      end
    end

    # Dirty tracking for DynamoDB models. It is written against a generic
    # attribute-dirty API that every DynamoDB backend (Dynamoid, aws-record)
    # must provide as public methods:
    #
    #   attribute_changed?(name)            # pending change on +name+
    #   attribute_was(name)                 # value before the pending change
    #   attribute_previously_changed?(name) # changed by the last save
    #   attribute_previous_change(name)     # [old, new] from the last save
    #   attribute_will_change!(name)        # force +name+ to count as changed
    #   devise_save_in_progress?            # true while save/create/update runs
    #
    # AR's after_update semantics are reproduced by reading the pending change
    # while a save is in progress and the applied change afterwards.
    module DirtyTrackingDynamodbMethods
      def devise_email_before_last_save
        devise_saved_before_value(:email)
      end

      def devise_email_in_database
        attribute_was(:email)
      end

      def devise_saved_change_to_email?
        devise_saved_change?(:email)
      end

      def devise_saved_change_to_encrypted_password?
        devise_saved_change?(:encrypted_password)
      end

      def devise_will_save_change_to_email?
        attribute_changed?(:email)
      end

      def devise_unconfirmed_email_will_change!
        attribute_will_change!(:unconfirmed_email)
      end

      # Like the ActiveRecord version, false for attributes the model does
      # not have (e.g. a configured authentication key it doesn't define).
      def devise_respond_to_and_will_save_change_to_attribute?(attribute)
        respond_to?("#{attribute}=") && attribute_changed?(attribute)
      end

      private

      def devise_saved_change?(name)
        if devise_save_in_progress?
          attribute_changed?(name)
        else
          attribute_previously_changed?(name)
        end
      end

      def devise_saved_before_value(name)
        if devise_save_in_progress?
          attribute_was(name)
        else
          change = attribute_previous_change(name)
          change ? change.first : attribute_was(name)
        end
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
  end
end
