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

        # Le sigh, ensure Thor won't handle opts as args
        # It should be fixed in future Rails releases
        class_option :form_builder, :aliases => "-b"
        class_option :markerb
        class_option :template, :type => :string, :aliases => "-t"

        public_task :copy_views
      end

      # TODO: Add this to Rails itself
      module ClassMethods
        def hide!
          Rails::Generators.hide_namespace self.namespace
        end
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
        directory name.to_s, _target_path || "#{target_path}/#{name}" do |content|
          if scope
            content.gsub "devise/shared/links", "#{scope}/shared/links"
          else
            content
          end
        end
      end
      
      def target_path
        @target_path ||= "app/views/#{scope || :devise}"
      end
    end

    class SharedViewsGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      desc "Copies shared Devise views to your application."
      hide!

      # Override copy_views to just copy mailer and shared.
      def copy_views
        view_directory :shared
      end
    end

    class FormForGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      desc "Copies default Devise views to your application."
      hide!
    end

    class SimpleFormForGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../templates/simple_form_for", __FILE__)
      desc "Copies simple form enabled views to your application."
      hide!
    end

    class ErbGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      desc "Copies Devise mail erb views to your application."
      hide!

      def copy_views
        view_directory :mailer
      end
    end

    class SlimGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      desc "Converts .erb view files to specified templating format"
      hide!
      
      def copy_views
        converts_to_slim
      end
      
      protected
      
      def converts_to_slim
        verify_slim_existence
        system( "for file in #{target_path}/**/*.erb; do erb2slim $file ${file%erb}slim && rm $file; done")
      end
      
      def verify_slim_existence
        begin
          require "html2slim"
        rescue LoadError
            say "html2slim is not installed, or it is not specified in your Gemfile."
          exit
        end
      end
      
    end
    
    class HamlGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      desc "Converts .erb view files to specified templating format"
      hide!
      
      def copy_views
        converts_to_haml
      end
      
      protected
      
      def converts_to_haml
        verify_haml_existence
        system( "for file in #{target_path}/**/*.erb; do html2haml -e $file ${file%erb}haml && rm $file; done")
      end
      
      def verify_haml_existence
        begin
          require "html2haml"
        rescue LoadError
            say "html2haml is not installed, or it is not specified in your Gemfile."
          exit
        end
      end
      
    end
    
    class MarkerbGenerator < Rails::Generators::Base #:nodoc:
      include ViewPathTemplates
      source_root File.expand_path("../../templates", __FILE__)
      desc "Copies Devise mail markerb views to your application."
      hide!

      def copy_views
        view_directory :markerb, target_path
      end

      def target_path
        "app/views/#{scope || :devise}/mailer"
      end
    end

    class ViewsGenerator < Rails::Generators::Base
      desc "Copies Devise views to your application."

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy views to",
                       :haml => false

      invoke SharedViewsGenerator

      hook_for :form_builder, :aliases => "-b",
                              :desc => "Form builder to be used",
                              :default => defined?(SimpleForm) ? "simple_form_for" : "form_for"

      hook_for :markerb,  :desc => "Generate markerb instead of erb mail views",
                          :default => defined?(Markerb) ? :markerb : :erb,
                          :type => :boolean
      
      hook_for :template, :aliases => "-t",
                      :desc => "Converts .erb view files to specified templating format. Available options are 'haml' and 'slim'",
                      :type => :string
      
    end
  end
end
