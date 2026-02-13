# frozen_string_literal: true

ActiveSupport.on_load(:mongoid) do
  Mongoid::Document::ClassMethods.send :include, Devise::Models
end
