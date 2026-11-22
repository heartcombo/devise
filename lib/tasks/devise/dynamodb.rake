# frozen_string_literal: true

namespace :devise do
  namespace :dynamodb do
    desc "Create the DynamoDB tables (and indexes) of your Devise models. Existing tables are not modified."
    task create_tables: :environment do
      require "devise/orm/dynamodb/tasks"
      Rails.application.eager_load!
      Devise::Orm::Dynamodb::Tasks.create_tables
    end

    desc "Report which Devise lookups on DynamoDB models would require a full table Scan."
    task check_indexes: :environment do
      require "devise/orm/dynamodb/tasks"
      Rails.application.eager_load!
      Devise::Orm::Dynamodb::Tasks.check_indexes
    end
  end
end
