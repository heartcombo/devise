require 'tmpdir'

module Devise
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/views", __FILE__)
      desc "Copies all Devise views to your application."

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy views to"

      class_option :template_engine, :type => :string, :aliases => "-t",
                                     :desc => "Template engine for the views. Available option is only 'erb'."

      def copy_views
        template = options[:template_engine].to_s
        case template
        when "haml", "slim"
          warn "#{template} templates have been removed from Devise gem"
        else
          directory "devise", "app/views/#{scope || :devise}"
        end
      end
    end
  end
end
