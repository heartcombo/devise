module Devise
  module Generators
    module OrmHelpers
      def model_contents
        buffer = <<-CONTENT
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

CONTENT
        buffer += <<-CONTENT if needs_attr_accessible?
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

CONTENT
        buffer
      end

      def needs_attr_accessible?
        if rails_3?
          !strong_parameters_enabled?
        else
          protected_attributes_enabled?
        end
      end

      def rails_3?
        Rails::VERSION::MAJOR == 3
      end

      def strong_parameters_enabled?
        defined?(ActionController::StrongParameters)
      end

      def protected_attributes_enabled?
        defined?(ActiveModel::MassAssignmentSecurity)
      end

      def model_exists?
        File.exists?(File.join(destination_root, model_path))
      end
      
      def migration_exists?(table_name)
        Dir.glob("#{File.join(destination_root, migration_path)}/[0-9]*_*.rb").grep(/\d+_add_devise_to_#{table_name}.rb$/).first
      end
      
      def migration_path
        @migration_path ||= File.join("db", "migrate")
      end

      def model_path
        @model_path ||= File.join("app", "models", "#{file_path}.rb")
      end
    end
  end
end
