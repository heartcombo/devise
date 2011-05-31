require 'tmpdir'

module Devise
  module Generators
    class ControllersGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/controllers", __FILE__)
      desc "Copies all Devise controllers to your application."

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy controllers to"


      def copy_controllers
        directory "devise", "app/controllers/#{scope || :devise}"
      end
    end
  end
end
