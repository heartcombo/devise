module Devise
  module Orm
    autoload :ActiveRecord, 'devise/orm/active_record'
    autoload :DataMapper,   'devise/orm/data_mapper'
    autoload :MongoMapper,  'devise/orm/mongo_mapper'
  end
end
