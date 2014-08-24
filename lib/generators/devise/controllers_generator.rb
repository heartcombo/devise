require 'rails/generators/base'

module Devise
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      def self.all_controllers
        @@controllers ||= %w(confirmations passwords registrations sessions unlocks omniauth_callbacks)
      end

      desc "Create inherited Devise controllers in your application."
      source_root File.expand_path("../../templates/controllers", __FILE__)
      argument :scope, required: true,
                       desc: "The scope to create controllers in, e.g. users, admins"
      class_option :controllers, aliases: "-c", type: :array, desc: "Select specific controllers to generate (#{all_controllers})"

      def create_controllers
        @scope_module = scope.camelize
        controllers = options[:controllers] || self.class.all_controllers
        controllers.each do |name|
          template "#{name}_controller.erb",
                   "app/controllers/#{scope}/#{name}_controller.rb"
        end
      end
    end
  end
end

