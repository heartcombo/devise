require 'test_helper'

class TrackableHooksTest < ActionController::IntegrationTest

  test "current and last sign in timestamps are updated on each sign in" do
    user = create_user
    assert_nil user.current_sign_in_at
    assert_nil user.last_sign_in_at

    sign_in_as_user
    user.reload

    assert_kind_of Time, user.current_sign_in_at
    assert_kind_of Time, user.last_sign_in_at

    assert_equal user.current_sign_in_at, user.last_sign_in_at
    assert user.current_sign_in_at >= user.created_at

    visit destroy_user_session_path
    new_time = 2.seconds.from_now
    Time.stubs(:now).returns(new_time)

    sign_in_as_user
    user.reload
    assert user.current_sign_in_at > user.last_sign_in_at
  end

  test "trackable stores ip addresses by default" do
    assert_equal true, Devise.trackable_stores_ip_addresses
  end

  test "current and last sign in remote ip are updated on each sign in" do
    user = create_user
    assert_nil user.current_sign_in_ip
    assert_nil user.last_sign_in_ip

    sign_in_as_user
    user.reload

    assert_equal "127.0.0.1", user.current_sign_in_ip
    assert_equal "127.0.0.1", user.last_sign_in_ip
  end

  test "current and last sign in remote ip are zeros if trackable is configured to ignore ip addrs" do
    Devise.trackable_stores_ip_addresses = false
    user = create_user
    sign_in_as_user
    user.reload

    assert_nil user.current_sign_in_ip
    assert_nil user.last_sign_in_ip

    Devise.trackable_stores_ip_addresses = true
  end

  test "increase sign in count" do
    user = create_user
    assert_equal 0, user.sign_in_count

    sign_in_as_user
    user.reload
    assert_equal 1, user.sign_in_count

    visit destroy_user_session_path
    sign_in_as_user
    user.reload
    assert_equal 2, user.sign_in_count
  end

  test "does not update anything if user has signed out along the way" do
    swap Devise, :confirm_within => 0 do
      user = create_user(:confirm => false)
      sign_in_as_user

      user.reload
      assert_nil user.current_sign_in_at
      assert_nil user.last_sign_in_at
    end
  end
end
