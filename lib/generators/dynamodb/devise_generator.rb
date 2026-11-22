# frozen_string_literal: true

require 'rails/generators/named_base'
require 'generators/devise/orm_helpers'

module Dynamodb
  module Generators
    class DeviseGenerator < Rails::Generators::NamedBase
      include Devise::Generators::OrmHelpers

      LIBRARIES = %w(dynamoid aws_record).freeze

      class_option :library, type: :string,
                             desc: "DynamoDB library for the model (#{LIBRARIES.join(' or ')}). " \
                                   "Defaults to Devise.dynamodb_library"

      def validate_library
        return if LIBRARIES.include?(library)

        raise Thor::Error, "Unknown DynamoDB library #{library.inspect}. Expected one of: #{LIBRARIES.join(', ')}."
      end

      def generate_model
        if behavior == :revoke && generated_model?
          # Thor's remove_file is a no-op under :revoke, so delete directly.
          File.delete(File.join(destination_root, model_path))
        elsif model_exists?
          inject_into_file model_path, "\n" + migration_data + model_contents, after: include_line
        else
          create_file model_path, model_template
        end
      end

      private

      def library
        @library ||= (options[:library] || default_library).to_s
      end

      def default_library
        Devise.respond_to?(:dynamodb_library) ? Devise.dynamodb_library : :dynamoid
      end

      def aws_record?
        library == "aws_record"
      end

      def generated_model?
        model_exists? && File.read(File.join(destination_root, model_path)) == model_template
      end

      def include_statement
        aws_record? ? "include Aws::Record" : "include Dynamoid::Document"
      end

      def include_line
        "#{include_statement}\n"
      end

      def model_template
        key = if aws_record?
                "  string_attr :id, hash_key: true\n\n" \
                "  ## Timestamps (Dynamoid adds these automatically)\n" \
                "  time_attr :created_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime\n" \
                "  time_attr :updated_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime\n\n"
              else
                ""
              end
        "class #{class_name}\n  #{include_statement}\n\n#{key}#{migration_data}#{model_contents}end\n"
      end

      def migration_data
        aws_record? ? aws_record_data : dynamoid_data
      end

      def dynamoid_data
<<-CONTENT
  ## Database authenticatable
  field :email, :string, default: ""
  field :encrypted_password, :string, default: ""

  ## Recoverable
  field :reset_password_token, :string
  field :reset_password_sent_at, :datetime

  ## Rememberable
  field :remember_created_at, :datetime

  ## Trackable
  # field :sign_in_count, :integer, default: 0
  # field :current_sign_in_at, :datetime
  # field :last_sign_in_at, :datetime
  # field :current_sign_in_ip, :string
  # field :last_sign_in_ip, :string

  ## Confirmable
  # field :confirmation_token, :string
  # field :confirmed_at, :datetime
  # field :confirmation_sent_at, :datetime
  # field :unconfirmed_email, :string # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token, :string # Only if unlock strategy is :email or :both
  # field :locked_at, :datetime

  ## Global secondary indexes (declared after the fields they use)
  global_secondary_index hash_key: :email, projected_attributes: :all
  global_secondary_index hash_key: :reset_password_token, projected_attributes: :all
  # global_secondary_index hash_key: :confirmation_token, projected_attributes: :all # Only if confirmable
  # global_secondary_index hash_key: :unconfirmed_email, projected_attributes: :all # Only if using reconfirmable
  # global_secondary_index hash_key: :unlock_token, projected_attributes: :all # Only if unlock strategy is :email or :both

CONTENT
      end

      def aws_record_data
<<-CONTENT
  ## Database authenticatable
  string_attr :email
  string_attr :encrypted_password

  ## Recoverable
  string_attr :reset_password_token
  time_attr :reset_password_sent_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  ## Rememberable
  time_attr :remember_created_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  ## Trackable
  # integer_attr :sign_in_count, default_value: 0
  # time_attr :current_sign_in_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  # time_attr :last_sign_in_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  # string_attr :current_sign_in_ip
  # string_attr :last_sign_in_ip

  ## Confirmable
  # string_attr :confirmation_token
  # time_attr :confirmed_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  # time_attr :confirmation_sent_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime
  # string_attr :unconfirmed_email # Only if using reconfirmable

  ## Lockable
  # integer_attr :failed_attempts, default_value: 0 # Only if lock strategy is :failed_attempts
  # string_attr :unlock_token # Only if unlock strategy is :email or :both
  # time_attr :locked_at, formatter: Devise::Orm::Dynamodb::AwsRecord::PreciseTime

  ## Global secondary indexes (declared after the attributes they use)
  global_secondary_index :email_index, hash_key: :email, projection: { projection_type: "ALL" }
  global_secondary_index :reset_password_token_index, hash_key: :reset_password_token, projection: { projection_type: "ALL" }
  # global_secondary_index :confirmation_token_index, hash_key: :confirmation_token, projection: { projection_type: "ALL" }
  # global_secondary_index :unconfirmed_email_index, hash_key: :unconfirmed_email, projection: { projection_type: "ALL" }
  # global_secondary_index :unlock_token_index, hash_key: :unlock_token, projection: { projection_type: "ALL" }

CONTENT
      end
    end
  end
end
