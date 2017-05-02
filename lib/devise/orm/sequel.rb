require 'orm_adapter-sequel'

 def self.apply(model, options = {})
   model.extend ::Devise::Models
   model.plugin :hook_class_methods # Devise requires a before_validation
 end
