# frozen_string_literal: true

require 'generators/dynamodb/devise_generator'

module AwsRecord
  module Generators
    # Used when the application sets `g.orm :aws_record`.
    # Same as `rails generate dynamodb:devise NAME --library=aws_record`.
    class DeviseGenerator < ::Dynamodb::Generators::DeviseGenerator
      source_root ::Dynamodb::Generators::DeviseGenerator.source_root
      remove_class_option :library

      no_tasks do
        def library
          "aws_record"
        end
      end
    end
  end
end
