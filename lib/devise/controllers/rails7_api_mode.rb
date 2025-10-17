# frozen_string_literal: true

module Devise
  module Controllers
    module Rails7ApiMode
      extend ActiveSupport::Concern

      class FakeRackSession < Hash
        def enabled?
          false
        end
      end

      included do
        before_action :set_fake_rack_session_for_devise
        
        private
    
        def set_fake_rack_session_for_devise
          if Rails.configuration.respond_to?(:api_only) && Rails.configuration.api_only
            request.env['rack.session'] ||= FakeRackSession.new
          end
        end
      end
    end
  end
end
