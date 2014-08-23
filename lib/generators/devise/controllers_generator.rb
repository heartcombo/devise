require 'rails/generators/base'

module Devise
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      desc "Create inherited Devise controllers in your application."
      source_root File.expand_path("../../templates/", __FILE__)
      argument :scope, required: false, default: nil,
                       desc: "The scope to create controllers in"

      def create_controllers
        directory "controllers", "app/controllers/#{scope || :devise}"
      end
    end
  end
end

