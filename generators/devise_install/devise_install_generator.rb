class DeviseInstallGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.file "devise.rb", "config/initializers/devise.rb"
    end
  end

end
