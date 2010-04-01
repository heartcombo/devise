require "test/test_helper"
require "rack/test"

class RackMiddlewareTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ActionController::Dispatcher.new
  end

  def warden
    last_request.env['warden']
  end

  def with_custom_strategy
    get '/'

    Warden::Strategies.add(:custom_test) do
      def valid?
        true
      end

      def authenticate!
        custom! [599, {
            "X-Custom-Response" => "Custom response test",
            "Content-type" => "text/plain"
          }, "Custom response test"]
      end
    end

    #ActionController::Dispatcher.middleware.use CustomStrategyInterceptor
    default_strategies = warden.manager.config.default_strategies
    warden.manager.config.default_strategies :custom_test
    yield
    warden.manager.config.default_strategies default_strategies
  end

  def test_custom_strategy_response
    with_custom_strategy do
      post('/users/sign_in')

      assert_equal 599, last_response.status
      assert_equal "Custom response test", last_response.body
      assert_equal "Custom response test", last_response.headers["X-Custom-Response"]
    end
  end
end