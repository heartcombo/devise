require 'devise/strategies/token_authenticatable'

module Devise
  module Models
    # The TokenAuthenticatable module is responsible for generating an authentication token and
    # validating the authenticity of the same while signing in.
    #
    # This module only provides a few helpers to help you manage the token, but it is up to you
    # to choose how to use it. For example, if you want to have a new token every time the user
    # saves his account, you can do the following:
    #
    #   before_save :reset_authentication_token
    #
    # On the other hand, if you want to generate token unless one exists, you should use instead:
    #
    #   before_save :ensure_authentication_token
    #
    # If you want to delete the token after it is used, you can do so in the
    # after_token_authentication callback.
    #
    # == APIs
    #
    # If you are using token authentication with APIs and using trackable. Every
    # request will be considered as a new sign in (since there is no session in
    # APIs). You can disable this by creating a before filter as follow:
    #
    #   before_filter :skip_trackable
    #
    #   def skip_trackable
    #     request.env['devise.skip_trackable'] = true
    #   end
    #
    # == Options
    #
    # TokenAuthenticatable adds the following options to devise_for:
    #
    #   * +token_authentication_key+: Defines name of the authentication token params key. E.g. /users/sign_in?some_key=...
    #
    module TokenAuthenticatable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:authentication_token]
      end

      # Generate new authentication token (a.k.a. "single access token").
      def reset_authentication_token
        self.authentication_token = self.class.authentication_token
      end

      # Generate new authentication token and save the record.
      def reset_authentication_token!
        reset_authentication_token
        save(:validate => false)
      end

      # Generate authentication token unless already exists.
      def ensure_authentication_token
        reset_authentication_token if authentication_token.blank?
      end

      # Generate authentication token unless already exists and save the record.
      def ensure_authentication_token!
        reset_authentication_token! if authentication_token.blank?
      end

      # Hook called after token authentication.
      def after_token_authentication
      end

      def expire_auth_token_on_timeout
        self.class.expire_auth_token_on_timeout
      end
      
      def valid_authentication_token?(authentication_token)
        return false if self.authentication_token.blank?
        Devise.secure_compare(self.authentication_token, authentication_token)
      end
      
      # Set password and password confirmation to nil
      def clean_up_passwords
        self.password = self.password_confirmation = nil
      end
      
      def update_with_authentication_token(params, *options)
        current_authentication_token = params.delete(:authentication_token)
      
        if params[:password].blank?
          params.delete(:password)
          params.delete(:password_confirmation) if params[:password_confirmation].blank?
        end
      
        result = if valid_authentication_token?(current_authentication_token)
          update_attributes(params, *options)
        else
          self.assign_attributes(params, *options)
          self.valid?
          self.errors.add(:authentication_token, current_authentication_token.blank? ? :blank : :invalid)
          false
        end
        
        clean_up_passwords
        result
      end

      module ClassMethods
        def find_for_token_authentication(conditions)
          find_for_authentication(:authentication_token => conditions[token_authentication_key])
        end

        # Generate a token checking if one does not already exist in the database.
        def authentication_token
          generate_token(:authentication_token)
        end

        Devise::Models.config(self, :token_authentication_key, :expire_auth_token_on_timeout)
      end
    end
  end
end
