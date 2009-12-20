require 'devise/serializers/base'

module Devise
  module Serializers
    # This serializer stores sign in information in th client session. It just
    # extends Warden own serializer to move all the serialization logic to a
    # class. For example, if a @user resource is given, it will call the following
    # two methods to serialize and deserialize a record:
    #
    #   User.serialize_into_session(@user)
    #   User.serialize_from_session(*args)
    #
    # This can be used any strategy and the default implementation is available
    # at Devise::Models::SessionSerializer.
    #
    class Session < Warden::Serializers::Session
      include Devise::Serializers::Base
    end
  end
end

Warden::Serializers.add(:session, Devise::Serializers::Session)
