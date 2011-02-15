require 'test_helper'
require 'ostruct'

class FailureTest < ActiveSupport::TestCase
  def self.context(name, &block)
    instance_eval(&block)
  end

  def call_failure(env_params={})
    env = {
      'REQUEST_URI' => 'http://test.host/',
      'HTTP_HOST' => 'test.host',
      'REQUEST_METHOD' => 'GET',
      'warden.options' => { :scope => :user },
      'rack.session' => {},
      'action_dispatch.request.formats' => Array(env_params.delete('formats') || Mime::HTML),
      'rack.input' => "",
      'warden' => OpenStruct.new(:message => nil)
    }.merge!(env_params)
    
    @response = Devise::FailureApp.call(env).to_a
    @request  = ActionDispatch::Request.new(env)
  end

  context 'When redirecting' do
    test 'return 302 status' do
      call_failure
      assert_equal 302, @response.first
    end

    test 'return to the default redirect location' do
      call_failure
      assert_equal 'You need to sign in or sign up before continuing.', @request.flash[:alert]
      assert_equal 'http://test.host/users/sign_in', @response.second['Location']
    end

    test 'uses the proxy failure message as symbol' do
      call_failure('warden' => OpenStruct.new(:message => :test))
      assert_equal 'test', @request.flash[:alert]
      assert_equal 'http://test.host/users/sign_in', @response.second["Location"]
    end

    test 'uses the proxy failure message as string' do
      call_failure('warden' => OpenStruct.new(:message => 'Hello world'))
      assert_equal 'Hello world', @request.flash[:alert]
      assert_equal 'http://test.host/users/sign_in', @response.second["Location"]
    end

    test 'set content type to default text/html' do
      call_failure
      assert_equal 'text/html; charset=utf-8', @response.second['Content-Type']
    end

    test 'setup a default message' do
      call_failure
      assert_match /You are being/, @response.last.body
      assert_match /redirected/, @response.last.body
      assert_match /users\/sign_in/, @response.last.body
    end

    test 'works for any navigational format' do
      swap Devise, :navigational_formats => [:xml] do
        call_failure('formats' => :xml)
        assert_equal 302, @response.first
      end
    end
  end

  context 'For HTTP request' do
    test 'return 401 status' do
      call_failure('formats' => :xml)
      assert_equal 401, @response.first
    end

    test 'return WWW-authenticate headers' do
      call_failure('formats' => :xml)
      assert_equal 'Basic realm="Application"', @response.second["WWW-Authenticate"]
    end

    test 'dont return WWW-authenticate on ajax call if http_authenticatable_on_xhr false' do
      swap Devise, :http_authenticatable_on_xhr => false do
        call_failure('formats' => :html, 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest')
        assert_equal 302, @response.first
        assert_equal 'http://test.host/users/sign_in', @response.second["Location"]
        assert_nil @response.second['WWW-Authenticate']
      end
    end

    test 'return WWW-authenticate on ajax call if http_authenticatable_on_xhr true' do
      swap Devise, :http_authenticatable_on_xhr => true do
        call_failure('formats' => :html, 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest')
        assert_equal 401, @response.first
        assert_equal 'Basic realm="Application"', @response.second["WWW-Authenticate"]
      end
    end
    
    test 'uses the proxy failure message as response body' do
      call_failure('formats' => :xml, 'warden' => OpenStruct.new(:message => :invalid))
      assert_match '<error>Invalid email or password.</error>', @response.third.body
    end

    test 'works for any non navigational format' do
      swap Devise, :navigational_formats => [] do
        call_failure('formats' => :html)
        assert_equal 401, @response.first
      end
    end
  end

  context 'With recall' do
    test 'calls the original controller' do
      env = {
        "action_dispatch.request.parameters" => { :controller => "devise/sessions" },
        "warden.options" => { :recall => "new", :attempted_path => "/users/sign_in" },
        "devise.mapping" => Devise.mappings[:user],
        "warden" => stub_everything
      }
      call_failure(env)
      assert @response.third.body.include?('<h2>Sign in</h2>')
      assert @response.third.body.include?('Invalid email or password.')
    end
  end
end
