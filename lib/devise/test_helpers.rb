module Devise
  # Devise::TestHelpers provides a facility to test controllers in isolation
  # when using ActionController::TestCase allowing you to quickly sign_in or
  # sign_out a user. Do not use Devise::TestHelpers in integration tests.
  #
  # Notice you should not test Warden specific behavior (like Warden callbacks)
  # using Devise::TestHelpers since it is a stub of the actual behavior. Such
  # callbacks should be tested in your integration suite instead.
  module TestHelpers
    def self.included(base)
      base.class_eval do
        setup :setup_controller_for_warden, :warden if respond_to?(:setup)
      end
    end

    def self.define_helpers(mapping)
      mapping ||= :user

      class_eval <<-METHODS, __FILE__, __LINE__ + 1
        def #{mapping}_session
          warden.session(:#{mapping})
        end
      METHODS
    end

    # Override process to consider warden.
    def process(*)
      # Make sure we always return @response, a la ActionController::TestCase::Behaviour#process, even if warden interrupts
      _catch_warden { super } || @response
    end

    # We need to setup the environment variables and the response in the controller.
    def setup_controller_for_warden #:nodoc:
      @request.env['action_controller.instance'] = @controller
      TestHelpers::define_helpers(:user)
    end

    # Quick access to Warden::Proxy.
    def warden #:nodoc:
      @request.env['warden'] ||= begin
        manager = Warden::Manager.new(nil) do |config|
          config.merge! Devise.warden_config
        end
        Warden::Proxy.new(@request.env, manager)
      end
    end

    # sign_in a given resource by storing its keys in the session.
    # This method bypass any warden authentication callback.
    #
    # Examples:
    #
    #   sign_in :user, @user   # sign_in(scope, resource)
    #   sign_in @user          # sign_in(resource)
    #
    def sign_in(resource_or_scope, resource=nil)
      scope    ||= Devise::Mapping.find_scope!(resource_or_scope)
      resource ||= resource_or_scope
      warden.instance_variable_get(:@users).delete(scope)
      warden.session_serializer.store(resource, scope)
    end

    # Sign out a given resource or scope by calling logout on Warden.
    # This method bypass any warden logout callback.
    #
    # Examples:
    #
    #   sign_out :user     # sign_out(scope)
    #   sign_out @user     # sign_out(resource)
    #
    def sign_out(resource_or_scope)
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      @controller.instance_variable_set(:"@current_#{scope}", nil)
      user = warden.instance_variable_get(:@users).delete(scope)
      warden.session_serializer.delete(scope, user)
    end

    protected

    # Catch warden continuations and handle like the middleware would.
    # Returns nil when interrupted, otherwise the normal result of the block.
    def _catch_warden(&block)
      result = catch(:warden, &block)

      env = @controller.request.env

      result ||= {}

      # Set the response. In production, the rack result is returned
      # from Warden::Manager#call, which the following is modelled on.
      case result
      when Array
        if result.first == 401 && intercept_401?(env) # does this happen during testing?
          _process_unauthenticated(env)
        else
          result
        end
      when Hash
        _process_unauthenticated(env, result)
      else
        result
      end
    end

    def _process_unauthenticated(env, options = {})
      options[:action] ||= :unauthenticated
      proxy = env['warden']
      result = options[:result] || proxy.result

      ret = case result
      when :redirect
        body = proxy.message || "You are being redirected to #{proxy.headers['Location']}"
        [proxy.status, proxy.headers, [body]]
      when :custom
        proxy.custom_response
      else
        env["PATH_INFO"] = "/#{options[:action]}"
        env["warden.options"] = options
        Warden::Manager._run_callbacks(:before_failure, env, options)

        status, headers, response = Devise.warden_config[:failure_app].call(env).to_a
        @controller.response.headers.merge!(headers)
        @controller.send :render, status: status, text: response.body,
          content_type: headers["Content-Type"], location: headers["Location"]
        nil # causes process return @response
      end

      # ensure that the controller response is set up. In production, this is
      # not necessary since warden returns the results to rack. However, at
      # testing time, we want the response to be available to the testing
      # framework to verify what would be returned to rack.
      if ret.is_a?(Array)
        # ensure the controller response is set to our response.
        @controller.response ||= @response
        @response.status = ret.first
        @response.headers = ret.second
        @response.body = ret.third
      end

      ret
    end
  end
end
