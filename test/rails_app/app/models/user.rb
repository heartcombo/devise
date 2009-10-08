class User < ActiveRecord::Base
  include Devise::Authenticable
  include Devise::Confirmable
  include Devise::Recoverable
  include Devise::Validatable
end
