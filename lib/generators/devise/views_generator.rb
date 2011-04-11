require 'tmpdir'

module Devise
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/views", __FILE__)
      desc "Copies all Devise views to your application."

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy views to"

      # class_option :template_engine, :type => :string, :aliases => "-t",
      #                                :desc => "Template engine for the views. Available options are 'erb', 'haml' and 'slim'."

      def copy_views
        directory "devise", "app/views/#{scope || :devise}"
      end
    end
  end
end
