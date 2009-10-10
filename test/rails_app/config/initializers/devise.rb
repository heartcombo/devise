Devise.map :users, :to => User, :for => [:authenticable, :recoverable, :confirmable]
Devise.map :account, :to => Account, :for => [:authenticable, :confirmable], :as => 'conta'
