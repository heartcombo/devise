module Devise
  module Generators
    module OrmHelpers
      def model_contents
<<-CONTENT
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :timeoutable and :oauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

CONTENT
      end

      def model_exists?
        return @model_exists if instance_variable_defined?(:@model_exists)
        @model_exists = File.exists?(File.join(destination_root, model_path))
      end

      def model_path
        @model_path ||= File.join("app", "models", "#{file_path}.rb")
      end
    end
  end
end