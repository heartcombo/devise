module Devise
  module OrmDirtyTracking # :nodoc:
    def self.activerecord51?
      defined?(ActiveRecord) && ActiveRecord.gem_version >= Gem::Version.new("5.1.x")
    end

    if activerecord51?
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
    else
      def devise_email_before_last_save
        email_was
      end

      def devise_email_in_database
        email_was
      end

      def devise_saved_change_to_email?
        email_changed?
      end

      def devise_saved_change_to_encrypted_password?
        encrypted_password_changed?
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
