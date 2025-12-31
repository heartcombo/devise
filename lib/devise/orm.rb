# frozen_string_literal: true

module Devise
  module Orm # :nodoc:
    def self.active_record?(model)
      defined?(ActiveRecord) && model < ActiveRecord::Base
    end

    def self.included(model)
      if Devise::Orm.active_record?(model)
        model.include DirtyTrackingActiveRecordMethods
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

      def devise_respond_to_and_will_save_change_to_attribute?(attribute)
        respond_to?("#{attribute}_changed?") && send("#{attribute}_changed?")
      end
    end
  end
end
