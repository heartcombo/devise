require 'active_support/secure_random'

module Devise
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Creates a Devise initializer and copy locale files to your application."
      class_option :orm

      def copy_initializer
        template "devise.rb", "config/initializers/devise.rb"
      end

      def copy_locale
        copy_file "../../../../../config/locales/en.yml", "config/locales/devise.en.yml"
      end

      def show_readme
        readme "README"
      end
    end
  end
end