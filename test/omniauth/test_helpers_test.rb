require 'test_helper'

class OmniAuthTestHelpersTest < ActiveSupport::TestCase
  test "Assert that stub! raises deprecation error" do
    assert_raises Devise::OmniAuth::TestHelpers::DeprecationError do
      Devise::OmniAuth::TestHelpers.stub!
    end
  end

  test "Assert that reset_stubs! raises deprecation error" do
    assert_raises Devise::OmniAuth::TestHelpers::DeprecationError do
      Devise::OmniAuth::TestHelpers.reset_stubs!
    end
  end

  test "Assert that short_circuit_authorizers! warns about deprecation" do
    Devise::OmniAuth::TestHelpers.short_circuit_authorizers!
    assert ::OmniAuth.config.test_mode
  end

  test "Assert that unshort_circuit_authorizers! warns about deprecation" do
    Devise::OmniAuth::TestHelpers.unshort_circuit_authorizers!
    assert ! ::OmniAuth.config.test_mode
  end
end
