require 'active_support/core_ext/object/with_options'

Devise.with_options :model => true do |d|
  # Strategies first
  d.with_options :strategy => true do |s|      
    s.add_module :database_authenticatable, :controller => :sessions, :route => :session
    s.add_module :token_authenticatable,    :controller => :sessions, :route => :session
    s.add_module :rememberable
  end

  # Misc after   
  d.add_module :recoverable,  :controller => :passwords,     :route => :password
  d.add_module :registerable, :controller => :registrations, :route => :registration
  d.add_module :validatable

  # The ones which can sign out after
  d.add_module :confirmable,  :controller => :confirmations, :route => :confirmation
  d.add_module :lockable,     :controller => :unlocks,       :route => :unlock
  d.add_module :timeoutable

  # Stats for last, so we make sure the user is really signed in
  d.add_module :trackable
end