module Devise
  module Serializers
    class Authenticatable < Warden::Serializers::Session
      include Devise::Serializers::Base
    end
  end
end

Warden::Serializers.add(:authenticatable, Devise::Serializers::Authenticatable)