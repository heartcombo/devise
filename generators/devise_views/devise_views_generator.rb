class DeviseViewsGenerator < Rails::Generator::Base

  def initialize(*args)
    super
    @source_root = options[:source] || File.join(spec.path, '..', '..', 'app', 'views')
  end

  def manifest
    record do |m|
      views_directory = File.join('app', 'views')
      m.directory views_directory

      Dir[File.join(@source_root, "**/*.erb")].each do |file|
        file = file.gsub(@source_root, "")[1..-1]

        m.directory  File.join(views_directory, File.dirname(file))
        m.file       file, File.join(views_directory, file)
      end
    end
  end

end
