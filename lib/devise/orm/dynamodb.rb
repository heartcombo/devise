# frozen_string_literal: true

# Devise ORM integration for Amazon DynamoDB.
#
# Two libraries are supported, selected with +Devise.dynamodb_library+:
#
#   * :dynamoid (default) - https://github.com/Dynamoid/dynamoid
#   * :aws_record         - https://github.com/aws/aws-sdk-ruby-record
#
# In config/initializers/devise.rb:
#
#   config.dynamodb_library = :dynamoid # or :aws_record
#   require 'devise/orm/dynamodb'
#
# The library can also be chosen with the DEVISE_DYNAMODB_LIBRARY environment
# variable, which takes precedence over the setting.
library = (ENV["DEVISE_DYNAMODB_LIBRARY"].presence || Devise.dynamodb_library).to_s.to_sym

unless Devise::DYNAMODB_LIBRARIES.include?(library)
  raise ArgumentError, "Unknown DynamoDB library #{library.inspect} for Devise. " \
    "Supported libraries are: #{Devise::DYNAMODB_LIBRARIES.map(&:inspect).join(', ')}."
end

Devise.dynamodb_library = library
require "devise/orm/#{library}"
