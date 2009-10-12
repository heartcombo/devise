Devise.map :user, :for => [:authenticable, :confirmable, :validatable]
Devise.map :admin, :for => [:authenticable, :recoverable, :confirmable, :validatable], :as => 'admin_area'
