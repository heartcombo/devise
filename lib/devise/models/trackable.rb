require 'devise/hooks/trackable'

module Devise
  module Models
    # Track information about your user sign in. It tracks the following columns:
    #
    # * sign_in_count      - Increased every time a sign in is made (by form, openid, oauth)
    # * current_sign_in_at - A tiemstamp updated when the user signs in
    # * last_sign_in_at    - Holds the timestamp of the previous sign in
    # * current_sign_in_ip - The remote ip updated when the user sign in
    # * last_sign_in_at    - Holds the remote ip of the previous sign in
    #
    module Trackable
    end
  end
end
