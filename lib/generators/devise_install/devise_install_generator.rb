class DeviseInstallGenerator < Rails::Generators::Base
  desc "Creates a Devise initializer and copy locale files to your application."

  def self.source_root
    @_devise_source_root ||= File.expand_path("../templates", __FILE__)
  end

  def copy_initializer
    template "devise.rb", "config/initializers/devise.rb"
  end

  def copy_locale
    copy_file "../../../../config/locales/en.yml", "config/locales/devise.en.yml"    
  end

  def show_readme
    readme "README"
  end

  protected
  
  def readme(path)
    say File.read(File.expand_path(path, self.class.source_root))
  end
end