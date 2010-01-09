class DeviseInstallGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.directory "config/initializers"
      m.template  "devise.rb", "config/initializers/devise.rb"

      m.directory "config/locales"
      m.file      "../../../lib/devise/locales/en.yml", "config/locales/devise.en.yml"

      m.readme "README"
    end
  end

end
