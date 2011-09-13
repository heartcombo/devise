module Devise
  module Generators
    # Include this module in your generator to generate Devise views.
    # `copy_views` is the main method and by default copies all views
    # with forms.
    module ViewPathTemplates #:nodoc:
      extend ActiveSupport::Concern

      included do
        argument :scope, :required => false, :default => nil,
                         :desc => "The scope to copy views to"

        public_task :copy_views
      end

      def copy_views
        view_directory :confirmations
        view_directory :passwords
        view_directory :registrations
        view_directory :sessions
        view_directory :unlocks
      end

      protected

      def view_directory(name, _target_path = nil)
        directory name.to_s, _target_path || "#{target_path}/#{name}"
      end

      def target_path
        @target_path ||= "app/views/#{scope || :devise}"
      end
    end

    class SharedViewsGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      desc "Copies shared Devise views to your application."

      # Override copy_views to just copy mailer and shared.
      def copy_views
        view_directory :shared
      end
    end

    class FormForGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      desc "Copies default Devise views to your application."
    end

    class SimpleFormForGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../templates/simple_form_for", __FILE__)
      desc "Copies simple form enabled views to your application."
    end

    class MailViewsGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise/mailer", __FILE__)
      desc "Copies Devise mail views to your application."
      class_option :mail_template_engine, :default => :erb, :aliases => "-m"

      def copy_views
        view_directory options[:mail_template_engine], target_path
      end

      def target_path
        "app/views/#{scope || :devise}/mailer"
      end
    end

    class ViewsGenerator < Rails::Generators::Base
      desc "Copies Devise views to your application."

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy views to"

      invoke SharedViewsGenerator
      invoke MailViewsGenerator
      hook_for :form_builder, :aliases => "-b",
                              :desc => "Form builder to be used",
                              :default => defined?(SimpleForm) ? "simple_form_for" : "form_for"
    end
  end
end
