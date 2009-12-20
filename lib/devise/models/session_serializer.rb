require 'devise/serializers/session'

module Devise
  module Models
    module SessionSerializer
      # Hook to serialize user into session. Overwrite if you want.
      def serialize_into_session(record)
        [record.class, record.id]
      end

      # Hook to serialize user from session. Overwrite if you want.
      def serialize_from_session(keys)
        klass, id = keys
        raise "#{self} cannot serialize from #{klass} session since it's not one of its ancestors" unless klass <= self
        klass.find(:first, :conditions => { :id => id })
      end
    end
  end
end