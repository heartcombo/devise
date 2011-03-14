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
        ::OmniAuth::Strategies.const_get("#{::OmniAuth::Utils.camelize(@provider.to_s)}")
      end
    end
  end
end     