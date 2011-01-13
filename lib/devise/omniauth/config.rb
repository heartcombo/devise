module Devise
  module OmniAuth
    class Config
      attr_accessor :strategy
      attr_reader :args

      def initialize(provider, args)
        @provider = provider
        @args     = args
        @strategy = nil
      end

      def strategy_class
        name = ::OmniAuth::Utils.camelize(@provider.to_s)
        ::OmniAuth::Strategies.const_get(name)
      rescue NameError
        ::OmniAuth::Strategies.const_get(name.upcase)
      end

      def check_if_allow_stubs!
        raise "OmniAuth strategy for #{@provider} does not allow stubs, only OAuth2 ones do." unless allow_stubs?
      end

      def allow_stubs?
        defined?(::OmniAuth::Strategies::OAuth2) && strategy.is_a?(::OmniAuth::Strategies::OAuth2)
      end

      def build_connection(&block)
        strategy.client.connection.build(&block)
      end
    end
  end
end     