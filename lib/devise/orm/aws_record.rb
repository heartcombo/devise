# frozen_string_literal: true

# Devise ORM integration for DynamoDB through aws-record
# (https://github.com/aws/aws-sdk-ruby-record). Prefer requiring
# 'devise/orm/dynamodb' and setting +config.dynamodb_library = :aws_record+.
require 'aws-record'
require 'devise/orm/dynamodb/aws_record_adapter'
require 'devise/orm/dynamodb/aws_record_model'

module Aws
  module Record
    # Lets Model.to_adapter find the adapter: OrmAdapter::ToAdapter looks up
    # the +OrmAdapter+ constant in the model's ancestors.
    OrmAdapter = ::Devise::Orm::Dynamodb::AwsRecordAdapter unless const_defined?(:OrmAdapter, false)

    module RecordClassMethods
      include ::OrmAdapter::ToAdapter
      include ::Devise::Models
    end
  end
end
