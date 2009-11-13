module Devise
  module Orm
    module ActiveRecord
      include Devise::Orm::Base
    end
  end
end


# Include alld devise definition about ActiveRecord
Rails.configuration.after_initialize do
  if defined?(ActiveRecord)
    ActiveRecord::Base.extend Devise::Models
    ActiveRecord::Base.extend Devise::Orm::ActiveRecord
    ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Devise::Migrations
  end
end
