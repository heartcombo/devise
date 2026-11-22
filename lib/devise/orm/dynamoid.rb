# frozen_string_literal: true

# Devise ORM integration for DynamoDB through Dynamoid
# (https://github.com/Dynamoid/dynamoid). Prefer requiring
# 'devise/orm/dynamodb', which picks the library configured in
# +Devise.dynamodb_library+ (:dynamoid by default).
require 'dynamoid'
require 'devise/orm/dynamodb/dynamoid_adapter'
require 'devise/orm/dynamodb/dynamoid_model'

module Dynamoid
  module Document
    # Lets Model.to_adapter find the adapter: OrmAdapter::ToAdapter looks up
    # the +OrmAdapter+ constant in the model's ancestors.
    OrmAdapter = ::Devise::Orm::Dynamodb::DynamoidAdapter unless const_defined?(:OrmAdapter, false)

    module ClassMethods
      include ::OrmAdapter::ToAdapter
      include ::Devise::Models
    end
  end
end
