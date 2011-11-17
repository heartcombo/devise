module Devise
  module OmniAuth
    class Config
      attr_accessor :strategy
      attr_reader :args, :options, :provider

      def initialize(provider, args)
        @provider = provider
        @args     = args
        @strategy = nil
        @options = @args.last.is_a?(Hash) ? @args.last : {}
      end

      # open_id strategy can have configurable name
      def strategy_name
        options[:name] || @provider
      end

      def strategy_class
        find_strategy || require_strategy
      end

      def find_strategy
        ::OmniAuth.strategies.find do |strategy_class|
          strategy_class.to_s =~ /#{::OmniAuth::Utils.camelize(strategy_name)}$/ ||
            strategy_class.default_options[:name] == strategy_name
        end
      end

      def require_strategy
        if [:facebook, :github, :twitter, :google_oauth2].include?(provider.to_sym)
          require "omniauth/strategies/#{provider}"
        elsif options[:require]
          require options[:require]
        else
          require "omniauth-#{provider}"
        end
        find_strategy || autoload_strategy
      rescue LoadError
        raise LoadError, "Could not load '#{provider}' strategy. Please ensure you have the gem 'omniauth-#{provider}' listed in your Gemfile cf https://github.com/intridea/omniauth/wiki/List-of-Strategies"
      end

      def autoload_strategy
        ::OmniAuth::Strategies.const_get(::OmniAuth::Utils.camelize(provider.to_s))
      end
    end
  end
end
