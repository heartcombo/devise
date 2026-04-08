# frozen_string_literal: true

require 'test_helper'

class Devise::TwoFactorHelperTest < Devise::IntegrationTest
  test 'two_factor_method_links returns empty string when no other methods' do
    resource = mock('resource')
    resource.stubs(:enabled_two_factors).returns([:test_two_factor])

    helper = Class.new(ActionView::Base) do
      include Devise::TwoFactorHelper
    end.new(ActionView::LookupContext.new([]), {}, nil)

    result = helper.two_factor_method_links(resource, :test_two_factor)
    assert_equal '', result
  end

  test 'two_factor_method_links renders link partials for other enabled methods' do
    resource = mock('resource')
    resource.stubs(:enabled_two_factors).returns([:webauthn, :totp, :backup_codes])

    helper = Class.new(ActionView::Base) do
      include Devise::TwoFactorHelper
    end.new(ActionView::LookupContext.new([]), {}, nil)

    helper.stubs(:render).with("devise/two_factor/totp_link").returns('<a href="/totp">Use TOTP</a>'.html_safe)
    helper.stubs(:render).with("devise/two_factor/backup_codes_link").returns('<a href="/backup">Use backup codes</a>'.html_safe)

    result = helper.two_factor_method_links(resource, :webauthn)
    assert_includes result, "Use TOTP"
    assert_includes result, "Use backup codes"
    assert_not_includes result, "webauthn"
  end
end
