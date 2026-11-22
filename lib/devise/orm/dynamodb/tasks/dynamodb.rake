# frozen_string_literal: true

namespace :devise do
  namespace :dynamodb do
    tables = lambda do
      unless defined?(Devise::Orm::Dynamodb::Tables)
        abort "Devise DynamoDB tasks need the DynamoDB ORM. Set `config.dynamodb_library` and " \
              "`require 'devise/orm/dynamodb'` in config/initializers/devise.rb, then retry."
      end

      Rails.application.eager_load!
      Devise::Orm::Dynamodb::Tables
    end

    desc "Create the DynamoDB tables for Devise models (existing tables are left untouched)"
    task create_tables: :environment do
      result = tables.call.create_all
      Array(result[:created]).sort.each { |name| puts "#{name} created" }
      Array(result[:existing]).sort.each { |name| puts "#{name} already exists" }
    end

    desc "Drop the DynamoDB tables for Devise models (set FORCE=true to drop in production)"
    task drop_tables: :environment do
      if Rails.env.production? && ENV["FORCE"] != "true"
        abort "Refusing to drop DynamoDB tables in production. Set FORCE=true to override."
      end

      tables.call.drop_all
      puts "DynamoDB tables dropped"
    end

    desc "Check that the configured DynamoDB endpoint can be reached"
    task ping: :environment do
      begin
        tables.call.ping
        puts "DynamoDB is reachable"
      rescue StandardError => e
        abort "DynamoDB is not reachable: #{e.message}"
      end
    end
  end
end
