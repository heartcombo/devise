require 'test_helper'

class OmniauthableTest < ActiveSupport::TestCase
  test 'required_fields should contain the fields that Devise uses' do
    assert_same_content Devise::Models::Omniauthable.required_fields(User), []
  end
end
