# frozen_string_literal: true

Devise.orm = :mongoid
ActiveSupport.on_load(:mongoid) do
  require 'orm_adapter/adapters/mongoid'

  Mongoid::Document::ClassMethods.send :include, Devise::Models
end
