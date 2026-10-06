# frozen_string_literal: true

require 'test_helper'
require 'open3'

class LazyRoutesTest < ActiveSupport::TestCase
  if Devise::Test.lazy_routes?
    test 'routes loader middleware runs before Warden::Manager' do
      names = Rails.application.middleware.map(&:name)

      assert_includes names, 'Devise::RoutesLoader'
      assert_operator names.index('Devise::RoutesLoader'), :<, names.index('Warden::Manager')
    end
  end

  test 'warden is fully configured on the first request of a fresh process' do
    assert_first_request_configures_warden boot_fresh_process_and_request
  end

  test 'does not load routes or models while booting outside local environments' do
    assert_first_request_configures_warden boot_fresh_process_and_request('DEVISE_PROBE_NON_LOCAL' => '1')
  end

  private

  # The suite already loaded the routes, so these need a process of their own.
  def boot_fresh_process_and_request(env = {})
    probe = File.expand_path('scripts/first_request_probe.rb', __dir__)
    output, status = Open3.capture2e(env, RbConfig.ruby, probe)
    assert status.success?, "probe failed:\n#{output}"

    JSON.parse(output[/^PROBE (.*)$/, 1])
  end

  def assert_first_request_configures_warden(result)
    if Devise::Test.lazy_routes?
      assert_equal 'Rails::Engine::LazyRouteSet', result['lazy_route_set']
      assert_not result['routes_loaded_after_boot']
      assert_not result['user_model_loaded_after_boot']
      assert result['routes_loaded_after_request']
    end
    assert_equal 'user', result['default_scope']
    assert_equal %w[rememberable database_authenticatable], result['user_strategies']
  end
end
