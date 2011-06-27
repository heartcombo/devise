module Devise
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      desc "Copies Devise views to your application."

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy views to"

      class_option :form_builder, :type => :string, :aliases => "-b",
                                  :desc => "Form builder to be used",
                                  :default => defined?(SimpleForm) ? "simple_form_for" : "form_for"

      def copy_views
        invoke SharedViewsGenerator

        if options[:form_builder] == "form_for"
          invoke DefaultViewsGenerator
        else
          invoke SimpleFormViewsGenerator
        end
      end
    end

    module ViewPathTemplates
      extend ActiveSupport::Concern

      included do
        source_root File.expand_path("../../../../app/views", __FILE__)

        argument :scope, :required => false, :default => nil,
                         :desc => "The scope to copy views to"
      end

      protected

      def view_directory(name)
        directory "devise/#{name}", "#{target_path}/#{name}"
      end

      def target_path
        @target_path ||= "app/views/#{scope || :devise}"
      end
    end

    class SharedViewsGenerator < Rails::Generators::Base
      include ViewPathTemplates
      desc "Copies shared Devise views to your application."

      def copy_views
        view_directory :mailer
        view_directory :shared
      end
    end

    class DefaultViewsGenerator < Rails::Generators::Base
      include ViewPathTemplates
      desc "Copies default Devise views to your application."

      def copy_views
        view_directory :confirmations
        view_directory :passwords
        view_directory :registrations
        view_directory :sessions
        view_directory :unlocks
      end
    end
  end
end
