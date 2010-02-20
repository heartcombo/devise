class DeviseViewsGenerator < Rails::Generators::Base
  desc "Copies all Devise views to your application."

  def self.source_root
    @_devise_source_root ||= File.expand_path("../../../../app/views", __FILE__)
  end

  def copy_views
    directory "devise"
  end

  def say_restart_server
    say "Views copied. Please restart your server."
  end
end