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

    class ErbGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      desc "Copies Devise mail erb views to your application."

      def copy_views
        view_directory :mailer
      end
    end

    class MarkerbGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../templates", __FILE__)
      desc "Copies Devise mail markerb views to your application."

      def copy_views
        view_directory :markerb, target_path
      end

      def target_path
        "app/views/#{scope || :devise}/mailer"
      end

      def inject_makerb_content
        if gemfile_exists?
          append_file gemfile_path, gemfile_content
        else
          create_file gemfile_path, gemfile_content
        end
      end

      def gemfile_path
        @gemfile_path ||= File.join("Gemfile")
      end

      def gemfile_exists?
        File.exists?(File.join(destination_root, gemfile_path))
      end

      def gemfile_content
        'gem "markerb"'
      end
    end

    class ViewsGenerator < Rails::Generators::Base
      desc "Copies Devise views to your application."

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy views to"

      invoke SharedViewsGenerator
      hook_for :form_builder, :aliases => "-b",
                              :desc => "Form builder to be used",
                              :default => defined?(SimpleForm) ? "simple_form_for" : "form_for"

      hook_for :markerb,  :desc => "Generate markerb instead of erb mail views",
                          :default => :erb,
                          :type => :boolean
    end
  end
end
