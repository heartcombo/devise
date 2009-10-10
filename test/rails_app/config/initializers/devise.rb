Devise.map :user, :for => [:authenticable, :recoverable, :confirmable, :validatable]
Devise.map :admin, :for => [:authenticable, :recoverable, :confirmable, :validatable], :as => 'admin_area'
