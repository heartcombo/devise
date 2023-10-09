# frozen_string_literal: true

# Strategies first
routes = [nil, :new, :destroy]
Devise.add_module :database_authenticatable, model: true, strategy: true, controller: :sessions, route: { session: routes }
Devise.add_module :rememberable, model: true, strategy: true, no_input: true

# Other authentications
Devise.add_module :omniauthable, model: true, controller: :omniauth_callbacks, route: :omniauth_callback

# Misc after
routes = [nil, :new, :edit]
Devise.add_module :recoverable, model: true, controller: :passwords, route: { password: routes }
Devise.add_module :registerable, model: true, controller: :registrations, route: { registration: (routes << :cancel) }
Devise.add_module :validatable, model: true

# The ones which can sign out after
routes = [nil, :new]
Devise.add_module :confirmable, model: true, controller: :confirmations, route: { confirmation: routes }
Devise.add_module :lockable, model: true, controller: :unlocks, route: { unlock: routes }
Devise.add_module :timeoutable, model: true

# Stats for last, so we make sure the user is really signed in
Devise.add_module :trackable, model: true
