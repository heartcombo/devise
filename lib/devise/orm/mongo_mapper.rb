require 'orm_adapter/adapters/mongo_mapper'

MongoMapper::Document::ClassMethods.send :include, Devise::Models