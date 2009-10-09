class User < ActiveRecord::Base
  include Devise::Models::Authenticable
  include Devise::Models::Confirmable
  include Devise::Models::Recoverable
  include Devise::Models::Validatable
end
