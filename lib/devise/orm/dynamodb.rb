# frozen_string_literal: true

# Loads the DynamoDB ORM for Devise. Set the library first, e.g. in
# config/initializers/devise.rb:
#
#   config.dynamodb_library = :dynamoid   # default
#   require "devise/orm/dynamodb"
#
# Supported libraries: :dynamoid (default), :aws_record.
module Devise
  module Orm
    module Dynamodb
      LIBRARIES = %i[dynamoid aws_record].freeze

      def self.library
        library = Devise.dynamodb_library.to_sym
        unless LIBRARIES.include?(library)
          raise ArgumentError, "Unknown Devise.dynamodb_library #{library.inspect}. " \
                               "Expected one of #{LIBRARIES.map(&:inspect).join(', ')}."
        end

        library
      end
    end
  end
end

# Fallback "has already been taken" message for the uniqueness validator.
# Prepended so the application's own translations win.
I18n.load_path.unshift(File.expand_path("dynamodb/locale/en.yml", __dir__))

case Devise::Orm::Dynamodb.library
when :dynamoid
  begin
    require "dynamoid"
  rescue LoadError => e
    raise LoadError, "Devise with :dynamodb needs the dynamoid gem. Add `gem \"dynamoid\"` to your Gemfile. (#{e.message})"
  end

  require "devise/orm/dynamodb/dynamoid"
  require "devise/orm/dynamodb/tables"
when :aws_record
  begin
    require "aws-record"
  rescue LoadError => e
    raise LoadError, "Devise with :dynamodb and aws_record needs the aws-record gem. Add `gem \"aws-record\"` to your Gemfile. (#{e.message})"
  end

  require "devise/orm/dynamodb/aws_record"
  require "devise/orm/dynamodb/tables"
end
