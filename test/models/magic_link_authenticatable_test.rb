# frozen_string_literal: true

require 'test_helper'

class MagicLinkAuthenticatableTest < ActiveSupport::TestCase

  def setup
    setup_mailer
  end

  test 'should not generate magic link token after creating a record' do
    assert_nil new_user.magic_link_token
  end

  test 'should never generate the same magic link token for different users' do
    magic_link_tokens = []
    3.times do
      user = create_user
      user.send_magic_link_instructions
      token = user.magic_link_token
      assert_not_includes magic_link_tokens, token
      magic_link_tokens << token
    end
  end

  test 'should generate a new magic link token and set the sent time' do
    user = create_user
    assert_nil user.magic_link_token
    assert_nil user.magic_link_sent_at

    user.send_magic_link_instructions

    assert_present user.magic_link_token
    assert_present user.magic_link_sent_at
  end

  test 'should return the raw token from send_magic_link_instructions' do
    user = create_user
    raw = user.send_magic_link_instructions

    assert_present raw
    assert_equal user, User.with_magic_link_token(raw)
  end

  test 'should store the digested token instead of the raw one' do
    user = create_user
    raw = user.send_magic_link_instructions

    assert_not_equal raw, user.magic_link_token
    assert_equal user.magic_link_token, Devise.token_generator.digest(User, :magic_link_token, raw)
  end

  test 'should regenerate magic link token, invalidating the previous one' do
    user = create_user
    old_raw = user.send_magic_link_instructions
    new_raw = user.send_magic_link_instructions

    assert_not_equal old_raw, new_raw
    assert_nil User.with_magic_link_token(old_raw)
    assert_equal user, User.with_magic_link_token(new_raw)
  end

  test 'should send email with magic link instructions' do
    user = create_user

    assert_difference 'ActionMailer::Base.deliveries.size' do
      user.send_magic_link_instructions
    end
  end

  test 'should find a user to send magic link instructions' do
    user = create_user
    magic_link_user = User.send_magic_link_instructions(email: user.email)
    assert_equal magic_link_user, user
  end

  test 'should return a new record with errors if user was not found by email' do
    magic_link_user = User.send_magic_link_instructions(email: 'invalid@example.com')
    assert_not magic_link_user.persisted?
    assert_equal 'not found', magic_link_user.errors[:email].join
  end

  test 'should return a new record with errors if email is blank' do
    magic_link_user = User.send_magic_link_instructions(email: '')
    assert_not magic_link_user.persisted?
    assert_equal "can't be blank", magic_link_user.errors[:email].join
  end

  test 'should find a user to send instructions by authentication_keys' do
    swap Devise, authentication_keys: [:username, :email] do
      user = create_user
      magic_link_user = User.send_magic_link_instructions(email: user.email)
      assert_equal magic_link_user, user
    end
  end

  test 'should require all magic_link_keys' do
    swap Devise, magic_link_keys: [:username, :email] do
      user = create_user
      magic_link_user = User.send_magic_link_instructions(email: user.email)
      assert_not magic_link_user.persisted?
      assert_equal "can't be blank", magic_link_user.errors[:username].join
    end
  end

  test 'should find a user by email case-insensitively to send magic link instructions' do
    user = create_user(email: 'MagicUser@example.com')
    magic_link_user = User.send_magic_link_instructions(email: 'magicuser@example.com')
    assert_equal magic_link_user, user
  end

  test 'should not send email to a user not found' do
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      User.send_magic_link_instructions(email: 'invalid@example.com')
    end
  end

  test 'magic link period should be valid within the configured window' do
    swap Devise, magic_link_within: 20.minutes do
      user = create_user
      user.send_magic_link_instructions

      assert user.magic_link_period_valid?

      user.magic_link_sent_at = 21.minutes.ago
      assert_not user.magic_link_period_valid?
    end
  end

  test 'magic link period should not be valid if token was never sent' do
    user = create_user
    assert_not user.magic_link_period_valid?
  end

  test 'magic link period can be configured per model' do
    swap Devise, magic_link_within: 20.minutes do
      swap_model_config User, magic_link_within: 1.hour do
        user = create_user
        user.send_magic_link_instructions
        user.magic_link_sent_at = 30.minutes.ago

        assert user.magic_link_period_valid?
      end
    end
  end

  test 'consume_magic_link_token! should clear the token and sent time' do
    user = create_user
    raw = user.send_magic_link_instructions

    user.consume_magic_link_token!

    assert_nil user.magic_link_token
    assert_nil user.magic_link_sent_at
    assert_nil User.with_magic_link_token(raw)
  end

  test 'with_magic_link_token should return nil for an unknown token' do
    assert_nil User.with_magic_link_token('invalid_token')
  end

  test 'should clear magic link token if changing email' do
    user = create_user
    user.send_magic_link_instructions
    assert_present user.magic_link_token

    user.email = 'another@example.com'
    user.save!
    assert_nil user.magic_link_token
    assert_nil user.magic_link_sent_at
  end

  test 'should clear magic link token if changing password' do
    user = create_user
    user.send_magic_link_instructions
    assert_present user.magic_link_token

    user.password = '123456789'
    user.password_confirmation = '123456789'
    user.save!
    assert_nil user.magic_link_token
  end

  test 'should not clear magic link token when updating unrelated attributes' do
    user = create_user
    user.send_magic_link_instructions
    assert_present user.magic_link_token

    user.username = 'another_username'
    user.save!
    assert_present user.magic_link_token
  end

  test 'magic_link_keys defaults to email' do
    assert_equal [:email], User.magic_link_keys
  end

  test 'should allow magic link requests up to the limit within the period' do
    swap Devise, magic_link_request_limit: 3, magic_link_request_period: 1.hour do
      user = create_user

      3.times do
        assert user.send_magic_link_instructions
      end
      assert_equal 3, user.magic_link_requests_count
    end
  end

  test 'should not send a magic link over the request limit and add an error' do
    swap Devise, magic_link_request_limit: 2, magic_link_request_period: 1.hour do
      user = create_user
      2.times { user.send_magic_link_instructions }

      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        assert_equal false, user.send_magic_link_instructions
      end

      assert_equal ['Too many magic links were requested. You can request a new one in about 1 hour.'],
        user.errors.full_messages
    end
  end

  test 'should not regenerate the token when the request is over the limit' do
    swap Devise, magic_link_request_limit: 1 do
      user = create_user
      raw = user.send_magic_link_instructions

      user.send_magic_link_instructions
      assert_equal user, User.with_magic_link_token(raw)
    end
  end

  test 'should reset the request counter after the period expires' do
    swap Devise, magic_link_request_limit: 2, magic_link_request_period: 1.hour do
      user = create_user
      2.times { user.send_magic_link_instructions }
      assert_equal false, user.send_magic_link_instructions

      user.update_attribute(:magic_link_first_request_at, 61.minutes.ago)

      assert user.send_magic_link_instructions
      assert_equal 1, user.magic_link_requests_count
    end
  end

  test 'magic_link_request_limit_exceeded? reflects the current state' do
    swap Devise, magic_link_request_limit: 1, magic_link_request_period: 1.hour do
      user = create_user
      assert_not user.magic_link_request_limit_exceeded?

      user.send_magic_link_instructions
      assert user.magic_link_request_limit_exceeded?

      user.update_attribute(:magic_link_first_request_at, 61.minutes.ago)
      assert_not user.reload.magic_link_request_limit_exceeded?
    end
  end

  test 'should persist the request counter along with the token' do
    user = create_user
    user.send_magic_link_instructions

    user.reload
    assert_equal 1, user.magic_link_requests_count
    assert_present user.magic_link_first_request_at
  end

  test 'should not rate limit magic link requests when the limit is disabled' do
    swap Devise, magic_link_request_limit: nil do
      user = create_user

      assert_difference 'ActionMailer::Base.deliveries.size', 3 do
        3.times { assert user.send_magic_link_instructions }
      end
      assert_not user.magic_link_request_limit_exceeded?
      assert_equal 0, user.magic_link_requests_count
    end
  end

  test 'magic link request limit can be configured per model' do
    swap Devise, magic_link_request_limit: 1 do
      swap_model_config User, magic_link_request_limit: 2 do
        user = create_user

        2.times { assert user.send_magic_link_instructions }
        assert_equal false, user.send_magic_link_instructions
      end
    end
  end

  test 'magic link rate limiting can be disabled per model with nil' do
    swap Devise, magic_link_request_limit: 1 do
      swap_model_config User, magic_link_request_limit: nil do
        user = create_user

        3.times { assert user.send_magic_link_instructions }
        assert_not user.magic_link_request_limit_exceeded?
      end
    end
  end

  test 'class level send_magic_link_instructions should return the record with errors when over the limit' do
    swap Devise, magic_link_request_limit: 1 do
      user = create_user
      user.send_magic_link_instructions

      magic_link_user = User.send_magic_link_instructions(email: user.email)
      assert_present magic_link_user.errors[:base]
    end
  end
end
