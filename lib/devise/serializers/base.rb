require 'devise/strategies/base'

module Devise
  module Serializers
    module Base
      include Devise::Strategies::Base
      attr_reader :scope

      def serialize(record)
        record.class.send(:"serialize_into_#{klass_type}", record)
      end

      def deserialize(keys)
        mapping.to.send(:"serialize_from_#{klass_type}", keys)
      end

      def fetch(scope)
        @scope = scope
        super
      end
    end
  end
end
