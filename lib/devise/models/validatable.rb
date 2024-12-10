# frozen_string_literal: true

module Devise
  module Models
    # Validatable creates all needed validations for a user email and password.
    # It's optional, given you may want to create the validations by yourself.
    # Automatically validate if the email is present, unique and its format is
    # valid. Also tests presence of password, confirmation and length.
    #
    # == Options
    #
    # Validatable adds the following options to +devise+:
    #
    #   * +email_regexp+: the regular expression used to validate e-mails;
    #   * +password_length+: a range expressing password length. Defaults to 6..128.
    #   * +password_complexity+: a hash with the password complexity requirements, with the following keys:
    #       - +require_lower+: a boolean to require a lower case letter in the password. Defaults to false.
    #       - +require_upper+: a boolean to require an upper case letter in the password. Defaults to false.
    #       - +require_special+: a boolean to require a special character in the password. Defaults to false.
    #       - +require_digit+: a boolean to require a digit in the password. Defaults to false.
    #       - +special_characters+: a string with the special characters that are allowed in the password. Defaults to nil.
    #
    # Since +password_length+ is applied in a proc within `validates_length_of` it can be overridden
    # at runtime.
    module Validatable
      # All validations used by this module.
      VALIDATIONS = [:validates_presence_of, :validates_uniqueness_of, :validates_format_of,
                     :validates_confirmation_of, :validates_length_of, :validate].freeze

      def self.required_fields(klass)
        []
      end

      def self.included(base)
        base.extend ClassMethods
        assert_validations_api!(base)

        base.class_eval do
          validates_presence_of   :email, if: :email_required?
          validates_uniqueness_of :email, allow_blank: true, case_sensitive: true, if: :devise_will_save_change_to_email?
          validates_format_of     :email, with: email_regexp, allow_blank: true, if: :devise_will_save_change_to_email?

          validates_presence_of     :password, if: :password_required?
          validates_confirmation_of :password, if: :password_required?
          validates_length_of       :password, minimum: proc { password_length.min }, maximum: proc { password_length.max }, allow_blank: true

          validates_format_of :password, with: /\p{Lower}/, if: -> { password_requires_lowercase }, message: :must_contain_lowercase
          validates_format_of :password, with: /\p{Upper}/, if: -> { password_requires_uppercase }, message: :must_contain_uppercase
          validates_format_of :password, with: /\d/, if: -> { password_requires_digit }, message: :must_contain_digit

          # Run as special character check as a custom validation to ensure password_special_characters is evaluated at runtime
          validate :password_must_contain_special_character, if: -> { password_requires_special_character }
        end
      end

      def self.assert_validations_api!(base) #:nodoc:
        unavailable_validations = VALIDATIONS.select { |v| !base.respond_to?(v) }

        unless unavailable_validations.empty?
          raise "Could not use :validatable module since #{base} does not respond " \
                "to the following methods: #{unavailable_validations.to_sentence}."
        end
      end

    protected

      # Checks whether a password is needed or not. For validations only.
      # Passwords are always required if it's a new record, or if the password
      # or confirmation are being set somewhere.
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end

      def email_required?
        true
      end

      # Make these instance methods so the default Devise.password_requires_<> 
      #can be overridden
      def password_complexity
        self.class.password_complexity
      end

      def password_requires_lowercase
        password_complexity[:require_lower]
      end

      def password_requires_uppercase
        password_complexity[:require_upper]
      end
      
      def password_requires_digit
        password_complexity[:require_digit]
      end
      
      def password_requires_special_character
        password_complexity[:require_special]
      end

      def password_special_characters
        password_complexity[:special_characters]
      end

      def password_must_contain_special_character
        special_character_regex = /[#{Regexp.escape(password_special_characters)}]/
      
        unless password =~ special_character_regex
          errors.add(:password, :must_contain_special_character)
        end
      end
      
      module ClassMethods
        Devise::Models.config(
          self,
          :email_regexp,
          :password_length,
          :password_complexity
        )
      end
    end
  end
end
