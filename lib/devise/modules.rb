require 'active_support/core_ext/object/with_options'

Devise.with_options :model => true do |d|
  # Strategies first
  d.with_options :strategy => true do |s|
    s.add_module :authenticatable,       :controller => :sessions, :flash => :invalid,       :route => :session
    s.add_module :http_authenticatable
    s.add_module :token_authenticatable, :controller => :sessions, :flash => :invalid_token, :route => :session
    s.add_module :rememberable
  end

  # Misc after   
  d.add_module :recoverable,  :controller => :passwords,     :route => :password
  d.add_module :registerable, :controller => :registrations, :route => :registration
  d.add_module :validatable

  # The ones which can sign out after
  d.add_module :activatable,                                 :flash => :inactive
  d.add_module :confirmable,  :controller => :confirmations, :flash => :unconfirmed, :route => :confirmation
  d.add_module :lockable,     :controller => :unlocks,       :flash => :locked,      :route => :unlock
  d.add_module :timeoutable,                                 :flash => :timeout

  # Stats for last, so we make sure the user is really signed in
  d.add_module :trackable
end