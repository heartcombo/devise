module Devise
  module Controllers
    # Helpers used in both FailureApp and Devise controllers.
    module SharedHelpers
      MIME_REFERENCES = Mime::HTML.respond_to?(:ref)

      protected

      # Helper used by FailureApp and Devise controllers to retrieve proper formats.
      def request_format
        @request_format ||= if request.format.respond_to?(:ref)
          request.format.ref
        elsif MIME_REFERENCES
          request.format
        elsif request.format # Rails < 3.0.4
          request.format.to_sym
        end
      end

      # Check whether it's navigational format, such as :html or :iphone, or not.
      def is_navigational_format?
        Devise.navigational_formats.include?(request_format)
      end
    end
  end
end