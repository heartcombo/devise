# frozen_string_literal: true

# The User model is defined twice, once per supported DynamoDB library, to show
# both. A real application only needs one of them: generate it with
# `rails generate devise User` (or `rails g dynamodb:devise User --library=aws_record`).
require Rails.root.join("app/models/#{Devise.dynamodb_library}/user").to_s
