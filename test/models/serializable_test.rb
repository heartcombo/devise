require 'test_helper'

class SerializableTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test 'should not include unsafe keys on XML' do
    assert_match /email/, @user.to_xml 
    assert_no_match /confirmation-token/, @user.to_xml 
  end

  test 'should not include unsafe keys on XML even if a new except is provided' do
    assert_no_match /email/, @user.to_xml(:except => :email)
    assert_no_match /confirmation-token/, @user.to_xml(:except => :email)
  end

  test 'should include unsafe keys on XML if a force_except is provided' do
    assert_no_match /email/, @user.to_xml(:force_except => :email)
    assert_match /confirmation-token/, @user.to_xml(:force_except => :email)
  end

  test 'should not include unsafe keys on JSON' do
    assert_match /"email":/, @user.to_json 
    assert_no_match /"confirmation_token":/, @user.to_json 
  end

  test 'should not include unsafe keys on JSON even if a new except is provided' do
    assert_no_match /"email":/, @user.to_json(:except => :email)
    assert_no_match /"confirmation_token":/, @user.to_json(:except => :email)
  end

  test 'should include unsafe keys on JSON if a force_except is provided' do
    assert_no_match /"email":/, @user.to_json(:force_except => :email)
    assert_match /"confirmation_token":/, @user.to_json(:force_except => :email)
  end

end
