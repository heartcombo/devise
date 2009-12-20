require 'devise/serializers/cookie'

module Devise
  module Models
    module CookieSerializer
      # Create the cookie key using the record id and remember_token
      def serialize_into_cookie(record)
        "#{record.id}::#{record.remember_token}"
      end

      # Recreate the user based on the stored cookie
      def serialize_from_cookie(cookie)
        record_id, record_token = cookie.split('::')
        record = find(:first, :conditions => { :id => record_id }) if record_id
        record if record.try(:valid_remember_token?, record_token)
      end

      Devise::Models.config(self, :remember_for)
    end
  end
end