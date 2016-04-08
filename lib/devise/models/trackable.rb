require 'devise/hooks/trackable'

module Devise
  module Models
    # Track information about your user sign in. It tracks the following columns:
    #
    # * sign_in_count      - Increased every time a sign in is made (by form, openid, oauth)
    # * current_sign_in_at - A timestamp updated when the user signs in
    # * last_sign_in_at    - Holds the timestamp of the previous sign in
    # * current_sign_in_ip - The remote ip updated when the user sign in
    # * last_sign_in_ip    - Holds the remote ip of the previous sign in
    # * device_type        - Gets device type (mobile, tablet, or desktop)
    module Trackable
      def self.required_fields(klass)
        [:current_sign_in_at, :current_sign_in_ip, :last_sign_in_at, :last_sign_in_ip, :sign_in_count, :device_type]
      end

      def update_tracked_fields(request)
        old_current, new_current = self.current_sign_in_at, Time.now.utc
        self.last_sign_in_at     = old_current || new_current
        self.current_sign_in_at  = new_current
  

        old_current, new_current = self.current_sign_in_ip, request.remote_ip
        self.last_sign_in_ip     = old_current || new_current
        self.current_sign_in_ip  = new_current

        self.sign_in_count ||= 0
        self.sign_in_count += 1

        #using mobvious gem--
        type_of_device = request.['mobvious.device_type']
        self.device_type = type_of_device            
      end

      def update_tracked_fields!(request)
        update_tracked_fields(request)
        save(validate: false)
      end
    end
  end
end
