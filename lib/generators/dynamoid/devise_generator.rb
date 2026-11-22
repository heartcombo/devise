# frozen_string_literal: true

require 'generators/dynamodb/devise_generator'

module Dynamoid
  module Generators
    # Used when the application sets `g.orm :dynamoid`.
    # Same as `rails generate dynamodb:devise NAME --library=dynamoid`.
    class DeviseGenerator < ::Dynamodb::Generators::DeviseGenerator
      source_root ::Dynamodb::Generators::DeviseGenerator.source_root
      remove_class_option :library

      no_tasks do
        def library
          "dynamoid"
        end
      end
    end
  end
end
