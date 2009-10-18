class Admin < ActiveRecord::Base
  devise :all, :except => [:recoverable, :confirmable]
end
