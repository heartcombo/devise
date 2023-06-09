module Devise
  module Orm # :nodoc:
    def self.active_record?(model)
      defined?(ActiveRecord) && model < ActiveRecord::Base
    end

    def self.included(model)
      model.include DirtyTrackingMethods
    end

    module DirtyTrackingMethods
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
  end
end
