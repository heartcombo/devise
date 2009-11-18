class DeviseInstallGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.template "devise.rb", "config/initializers/devise.rb"
    end
  end

end
