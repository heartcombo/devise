class Admin < ActiveRecord::Base
  devise :all, :except => [:recoverable, :confirmable, :rememberable, :validatable]
end
