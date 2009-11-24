module Devise
  module Models

    # Validatable creates all needed validations for a user email and password.
    # It's optional, given you may want to create the validations by yourself.
    # Automatically validate if the email is present, unique and it's format is
    # valid. Also tests presence of password, confirmation and length
    module Validatable

      # Email regex used to validate email formats. Retrieved from authlogic.
      EMAIL_REGEX = /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)\z/i

      # All validations used by this module.
      VALIDATIONS = [ :validates_presence_of, :validates_uniqueness_of, :validates_format_of,
                      :validates_confirmation_of, :validates_length_of ].freeze

      def self.included(base)
        assert_validations_api!(base)

        base.class_eval do
          attribute = authentication_keys.first

          validates_presence_of   attribute
          validates_uniqueness_of attribute, :allow_blank => true
          validates_format_of     attribute, :with => EMAIL_REGEX, :allow_blank => true,
                                              :scope => authentication_keys[1..-1]

          with_options :if => :password_required? do |v|
            v.validates_presence_of     :password
            v.validates_confirmation_of :password
            v.validates_length_of       :password, :within => 6..20, :allow_blank => true
          end
        end
      end

      def self.assert_validations_api!(base) #:nodoc:
        unavailable_validations = VALIDATIONS.select { |v| !base.respond_to?(v) }

        unless unavailable_validations.empty?
          raise "Could not use :validatable module since #{base} does not respond " <<
                "to the following methods: #{unavailable_validations.to_sentence}."
        end
      end

      protected

        # Checks whether a password is needed or not. For validations only.
        # Passwords are always required if it's a new record, or if the password
        # or confirmation are being set somewhere.
        def password_required?
          new_record? || !password.nil? || !password_confirmation.nil?
        end
    end
  end
end
