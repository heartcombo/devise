module Devise
  module Validatable

    # Email regex used to validate email formats
    #
    EMAIL_REGEX = /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)\z/i

    def self.included(base)
      base.class_eval do

        validates_presence_of     :email
        validates_uniqueness_of   :email, :allow_blank => true
        validates_format_of       :email, :with => EMAIL_REGEX, :allow_blank => true

        validates_presence_of     :password, :if => :password_required?
        validates_confirmation_of :password, :if => :password_required?
        validates_length_of       :password, :within => 6..20, :allow_blank => true
      end
    end

    private

      # Checks whether a password is needed or not. For validations only.
      #
      def password_required?
        new_record? || !password.nil? || !password_confirmation.nil?
      end
  end
end

