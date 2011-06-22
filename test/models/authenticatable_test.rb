require 'test_helper'

class AuthenticatableTest < ActiveSupport::TestCase
  test 'should not include critical Devise fields in its serializable_hash' do
    user = new_user
    hash = user.serializable_hash

    Devise.attributes_excluded_from_serializable_hash.each { |field| assert !hash.key?(field) }
  end

  test 'should include critical Devise fields in its serializable_hash if explicitly asked for with :only' do
    user = new_user
    hash = user.serializable_hash(:only => :encrypted_password)

    assert_not_nil hash['encrypted_password']
  end

  test 'should include critical Devise fields in its serializable_hash if :except is overridden' do
    user = new_user
    hash = user.serializable_hash(:except => :id)

    assert_not_nil hash['encrypted_password']
  end
end
