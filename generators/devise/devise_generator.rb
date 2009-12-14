require File.expand_path(File.dirname(__FILE__) + "/lib/route_devise.rb")

class DeviseGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      # Model
      m.directory(File.join('app', 'models', class_path))
      m.template 'model.rb', File.join('app', 'models', "#{file_path}.rb")

      # Migration
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "devise_create_#{table_name}"

      # Routing
      m.route_devise table_name

      # Readme
      m.readme "README"
    end
  end

end
