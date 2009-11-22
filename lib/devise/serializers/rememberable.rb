module Devise
  module Serializers
    class Rememberable < Warden::Serializers::Cookie
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

Warden::Serializers.add(:rememberable, Devise::Serializers::Rememberable)
