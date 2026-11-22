# frozen_string_literal: true

require 'rails/generators/named_base'
require 'generators/devise/orm_helpers'

module Dynamodb
  module Generators
    # Generates (or updates) a DynamoDB model with Devise.
    #
    #   rails generate devise User                          # with g.orm :dynamodb
    #   rails generate dynamodb:devise User --library=aws_record
    #
    # DynamoDB is schemaless, so there are no migrations: the attributes are
    # declared in the model. Create the table afterwards with
    # `rails devise:dynamodb:create_tables`.
    class DeviseGenerator < Rails::Generators::NamedBase
      include Devise::Generators::OrmHelpers

      LIBRARIES = %w(dynamoid aws_record).freeze

      source_root File.expand_path("../templates", __FILE__)

      class_option :library, type: :string, desc: "DynamoDB library: #{LIBRARIES.join(' or ')} " \
        "(defaults to Devise.dynamodb_library, i.e. dynamoid)"

      def check_library
        return if LIBRARIES.include?(library)

        raise Thor::Error, "Unknown DynamoDB library #{library.inspect}. Use one of: #{LIBRARIES.join(', ')}."
      end

      def generate_model
        template "#{library}_model.rb.tt", model_path unless model_exists? && behavior == :invoke
      end

      def inject_devise_content
        return unless model_exists? && behavior == :invoke
        return if File.read(File.join(destination_root, model_path)).include?("devise :")

        inject_into_file model_path, "#{field_definitions}\n#{model_contents}", after: library_include_line
      end

      no_tasks do
        def library
          (options[:library] || default_library).to_s
        end

        def field_definitions
          if library == "aws_record"
            aws_record_fields
          else
            dynamoid_fields
          end
        end

        def dynamoid_fields
<<RUBY
  ## Database authenticatable
  field :email,              :string, default: ""
  field :encrypted_password, :string, default: ""

  # Looks up users by email with a Query instead of a full table Scan.
  global_secondary_index hash_key: :email, projected_attributes: :all

  ## Recoverable
  field :reset_password_token,   :string
  field :reset_password_sent_at, :datetime
  # global_secondary_index hash_key: :reset_password_token, projected_attributes: :all

  ## Rememberable
  field :remember_created_at, :datetime

  ## Trackable
  # field :sign_in_count,      :integer, default: 0
  # field :current_sign_in_at, :datetime
  # field :last_sign_in_at,    :datetime
  # field :current_sign_in_ip, :string
  # field :last_sign_in_ip,    :string

  ## Confirmable
  # field :confirmation_token,   :string
  # field :confirmed_at,         :datetime
  # field :confirmation_sent_at, :datetime
  # field :unconfirmed_email,    :string # Only if using reconfirmable
  # global_secondary_index hash_key: :confirmation_token, projected_attributes: :all

  ## Lockable
  # field :failed_attempts, :integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :string # Only if unlock strategy is :email or :both
  # field :locked_at,       :datetime
  # global_secondary_index hash_key: :unlock_token, projected_attributes: :all
RUBY
        end

        def aws_record_fields
<<RUBY
  ## Database authenticatable
  string_attr :email
  string_attr :encrypted_password

  # Looks up users by email with a Query instead of a full table Scan.
  global_secondary_index :email_index, hash_key: :email, projection: { projection_type: "ALL" }

  ## Recoverable
  string_attr :reset_password_token
  time_attr   :reset_password_sent_at
  # global_secondary_index :reset_password_token_index, hash_key: :reset_password_token, projection: { projection_type: "ALL" }

  ## Rememberable
  time_attr :remember_created_at

  ## Trackable
  # integer_attr :sign_in_count, default_value: 0
  # time_attr    :current_sign_in_at
  # time_attr    :last_sign_in_at
  # string_attr  :current_sign_in_ip
  # string_attr  :last_sign_in_ip

  ## Confirmable
  # string_attr :confirmation_token
  # time_attr   :confirmed_at
  # time_attr   :confirmation_sent_at
  # string_attr :unconfirmed_email # Only if using reconfirmable
  # global_secondary_index :confirmation_token_index, hash_key: :confirmation_token, projection: { projection_type: "ALL" }

  ## Lockable
  # integer_attr :failed_attempts, default_value: 0 # Only if lock strategy is :failed_attempts
  # string_attr  :unlock_token # Only if unlock strategy is :email or :both
  # time_attr    :locked_at
  # global_secondary_index :unlock_token_index, hash_key: :unlock_token, projection: { projection_type: "ALL" }
RUBY
        end
      end

      private

      def default_library
        defined?(Devise) && Devise.respond_to?(:dynamodb_library) ? Devise.dynamodb_library : :dynamoid
      end

      def library_include_line
        library == "aws_record" ? /include Aws::Record\n/ : /include Dynamoid::Document\n/
      end
    end
  end
end
