class DeviseViewsGenerator < Rails::Generator::Base

  def initialize(*args)
    super
    @source_root = options[:source] || File.join(spec.path, '..', '..')
  end

  def manifest
    record do |m|
      m.directory "app/views"

      Dir[File.join(@source_root, "app", "views", "**/*.erb")].each do |file|
        file = file.gsub(@source_root, "")[1..-1]

        m.directory  File.dirname(file)
        m.file       file, file
      end

      m.directory "config/locales"
      m.file "lib/devise/locales/en.yml", "config/locales/devise.en.yml"
    end
  end

end
