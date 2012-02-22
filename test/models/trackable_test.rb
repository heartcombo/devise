require 'test_helper'

class TrackableTest < ActiveSupport::TestCase
  test 'required_fields should contain the fields that Devise uses' do
    assert_same_content Devise::Models::Trackable.required_fields(User), [
      :current_sign_in_at,
      :current_sign_in_ip,
      :last_sign_in_at,
      :last_sign_in_ip,
      :sign_in_count
    ]
  end
end
