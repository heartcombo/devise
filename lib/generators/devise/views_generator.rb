require 'tmpdir'

module Devise
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/views", __FILE__)
      desc "Copies all Devise views to your application."

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy views to"

      class_option :template_engine, :type => :string, :aliases => "-t",
                                     :desc => "Template engine for the views. Available options are 'erb', 'haml' and 'slim'."

      def copy_views
        case options[:template_engine].to_s
        when "haml"
          verify_haml_existence
          verify_haml_version
          create_and_copy_haml_views
        when "slim"
          verify_haml_existence
          verify_haml_version
          verify_haml2slim_existence
          verify_haml2slim_version
          create_and_copy_slim_views
        else
          directory "devise", "app/views/#{scope || :devise}"
        end
      end

    protected

      def verify_haml_existence
        begin
          require 'haml'
        rescue LoadError
          say "Haml is not installed, or it is not specified in your Gemfile."
          exit
        end
      end

      def verify_haml2slim_existence
        begin
          require 'haml2slim'
        rescue LoadError
          say "Haml2Slim is not installed, or it is not specified in your Gemfile."
          exit
        end
      end

      def verify_haml_version
        unless Haml.version[:major] == 2 && Haml.version[:minor] >= 3 || Haml.version[:major] >= 3
          say "To generate Haml or Slim templates, you need to have Haml 2.3 or above installed."
          exit
        end
      end

      def verify_haml2slim_version
        unless Haml2Slim::VERSION.to_f >= '0.4.0'.to_f
          say "To generate Slim templates, you need to have Haml2Slim 0.4.0 or above installed."
          exit
        end
      end

      def create_and_copy_haml_views
        directory haml_tmp_root, "app/views/#{scope || :devise}"
        FileUtils.rm_rf(haml_tmp_root)
      end

      def create_and_copy_slim_views
        slim_tmp_root = Dir.mktmpdir("devise-slim.")
        `haml2slim #{haml_tmp_root} #{slim_tmp_root}`

        directory slim_tmp_root, "app/views/#{scope || :devise}"

        FileUtils.rm_rf(haml_tmp_root)
        FileUtils.rm_rf(slim_tmp_root)
      end

    private

      def create_haml_views
        @haml_tmp_root ||= begin
          html_root     = "#{self.class.source_root}/devise"
          haml_tmp_root = Dir.mktmpdir("devise-haml.")

          Dir["#{html_root}/**/*"].each do |path|
            relative_path = path.sub(html_root, "")
            source_path   = (haml_tmp_root + relative_path).sub(/erb$/, "haml")

            if File.directory?(path)
              FileUtils.mkdir_p(source_path)
            else
              `html2haml -r #{path} #{source_path}`
            end
          end

          haml_tmp_root
        end
      end

      alias :haml_tmp_root :create_haml_views
    end
  end
end
