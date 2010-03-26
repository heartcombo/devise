require 'rails/generators/migration'

class DeviseGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  desc "Generates a model with the given NAME (if one does not exist) with devise " <<
       "configuration plus a migration file and devise routes."

  def self.source_root
    @_devise_source_root ||= File.expand_path("../templates", __FILE__)
  end

  def self.orm_has_migration?
    Rails::Generators.options[:rails][:orm] == :active_record
  end

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  class_option :orm
  class_option :migration, :type => :boolean, :default => orm_has_migration?

  def invoke_orm_model
    if model_exists?
      say "* Model already exists. Adding Devise behavior."
    else
      invoke "model", [name], :migration => false, :orm => options[:orm]

      unless model_exists?
        abort "Tried to invoke the model generator for '#{options[:orm]}' but could not find it.\n" <<
              "Please create your model by hand before calling `rails g devise #{name}`."
      end
    end
  end

  def inject_devise_config_into_model
    inject_into_class model_path, class_name, <<-CONTENT
  # Include default devise modules. Others available are:
  # :http_authenticatable, :token_authenticatable, :lockable, :timeoutable and :activatable
  devise :registerable, :authenticatable, :confirmable, :recoverable,
         :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
CONTENT
  end

  def copy_migration_template
    return unless options.migration?
    migration_template "migration.rb", "db/migrate/devise_create_#{table_name}"
  end

  def add_devise_routes
    route "devise_for :#{table_name}"
  end

  protected

    def model_exists?
      File.exists?(File.join(destination_root, model_path))
    end

    def model_path
      @model_path ||= File.join("app", "models", "#{file_path}.rb")
    end
end
