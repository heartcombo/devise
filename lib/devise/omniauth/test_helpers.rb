module Devise
  module OmniAuth
    module TestHelpers
      def self.test_mode!
        Faraday.default_adapter = :test if defined?(Faraday)
        ActiveSupport.on_load(:action_controller) { include Devise::OmniAuth::TestHelpers }
        ActiveSupport.on_load(:action_view) { include Devise::OmniAuth::TestHelpers }
      end

      def self.stub!(provider, stubs=nil, &block)
        raise "You either need to pass stubs as a block or as a parameter" unless block_given? || stubs

        config = Devise.omniauth_configs[provider]
        raise "Could not find configuration for #{provider.to_s} omniauth provider" unless config

        config.check_if_allow_stubs!
        stubs ||= Faraday::Adapter::Test::Stubs.new(&block)

        config.build_connection do |b|
          b.adapter :test, stubs
        end
      end

      def self.reset_stubs!(*providers)
        target = providers.any? ? Devise.omniauth_configs.slice(*providers) : Devise.omniauth_configs
        target.each_value do |config|
          next unless config.allow_stubs?
          config.build_connection { |b| b.adapter Faraday.default_adapter }
        end
      end

      def self.short_circuit_authorizers!
        module_eval <<-ALIASES, __FILE__, __LINE__ + 1
          def omniauth_authorize_path(*args)
            omniauth_callback_path(*args)
          end
        ALIASES

        Devise.mappings.each_value do |m|
          next unless m.omniauthable?

          module_eval <<-ALIASES, __FILE__, __LINE__ + 1
            def #{m.name}_omniauth_authorize_path(provider)
              #{m.name}_omniauth_callback_path(provider)
            end
          ALIASES
        end
      end

      def self.unshort_circuit_authorizers!
        module_eval do
          instance_methods.each { |m| remove_method(m) }
        end
      end
    end
  end
end