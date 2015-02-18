module Devise
  module Models
    # Gather methods used for blasting ActiveSupport::Notifications
    module Instrumentation

      protected

        def instrument name, payload = {}, &block
          payload.reverse_merge! default_instrument_payload
          ActiveSupport::Notifications.instrument name, payload, &block
        end

      private

        def default_instrument_payload
          { "#{ self.class.model_name.element }_id" => self.id }
        end

    end
  end
end
