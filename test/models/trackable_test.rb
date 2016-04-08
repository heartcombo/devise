require 'test_helper'

class TrackableTest < ActiveSupport::TestCase
  test 'required_fields should contain the fields that Devise uses' do
    assert_same_content Devise::Models::Trackable.required_fields(User), [
      :current_sign_in_at,
      :current_sign_in_ip,
      :last_sign_in_at,
      :last_sign_in_ip,
      :sign_in_count,
      :device_type
    ]
  end

  test 'update_tracked_fields should only set attributes but not save the record' do
    user = create_user
    request = mock
    request.stubs(:remote_ip).returns("127.0.0.1")

    assert_nil user.current_sign_in_ip
    assert_nil user.last_sign_in_ip
    assert_nil user.current_sign_in_at
    assert_nil user.last_sign_in_at
    assert_equal 0, user.sign_in_count
    assert_nil user.device_type     

    user.update_tracked_fields(request)

    assert_equal "127.0.0.1", user.current_sign_in_ip
    assert_equal "127.0.0.1", user.last_sign_in_ip
    assert_not_nil user.current_sign_in_at
    assert_not_nil user.last_sign_in_at
    assert_equal 1, user.sign_in_count
    assert_not_nil user.device_type

    user.reload

    assert_nil user.current_sign_in_ip
    assert_nil user.last_sign_in_ip
    assert_nil user.current_sign_in_at
    assert_nil user.last_sign_in_at
    assert_equal 0, user.sign_in_count
    assert_nil user.device_type
  end
end
