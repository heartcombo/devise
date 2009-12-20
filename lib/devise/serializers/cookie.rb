require 'devise/serializers/base'

module Devise
  module Serializers
    # This is a cookie serializer which stores the information if a :remember_me
    # is sent in the params and if the model responds to remember_me! as well.
    # As in Session serializer, the invoked methods are:
    #
    #   User.serialize_into_cookie(@user)
    #   User.serialize_from_cookie(*args)
    #
    # An implementation for such methods can be found at Devise::Models::Rememberable.
    #
    # Differently from session, this approach is based in a token which is stored in
    # the database. So if you want to sign out all clients at once, you just need to
    # clean up the token column.
    #
    class Cookie < Warden::Serializers::Cookie
      include Devise::Serializers::Base

      def store(record, scope)
        remember_me = params[scope].try(:fetch, :remember_me, nil)
        if Devise::TRUE_VALUES.include?(remember_me) && record.respond_to?(:remember_me!)
          record.remember_me!
          super
        end
      end

      def default_options(record)
        super.merge!(:expires => record.remember_expires_at)
      end

      def delete(scope, record=nil)
        if record && record.respond_to?(:forget_me!)
          record.forget_me! 
          super
        end
      end
    end
  end
end

Warden::Serializers.add(:cookie, Devise::Serializers::Cookie)
