require 'rails/generators/base'

module Devise
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      def self.all_controllers
        @@controllers ||= %w(confirmations passwords registrations sessions unlocks omniauth_callbacks)
      end

      desc <<-DESC
Create inherited Devise controllers in your app/controllers folder.

User -c to specify which controller you want to overwrite.
If you do no specify a controller, all controllers will be created.
For example:

  rails generate devise:controllers users -c=sessions

This will create a controller class at app/controllers/users/sessions_controller.rb like this:

  class Users::ConfirmationsController < Devise::ConfirmationsController
    content...
  end
      DESC

      source_root File.expand_path("../../templates/controllers", __FILE__)
      argument :scope, required: false, default: nil,
                       desc: "The scope to create controllers in, e.g. users, admins"
      class_option :controllers, aliases: "-c", type: :array, desc: "Select specific controllers to generate (#{all_controllers.join(', ')})"

      def create_controllers
        @scope_prefix = scope.blank? ? '' : (scope.camelize + '::')
        controllers = options[:controllers] || self.class.all_controllers
        controllers.each do |name|
          template "#{name}_controller.erb",
                   "app/controllers/#{scope}/#{name}_controller.rb"
        end
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end

