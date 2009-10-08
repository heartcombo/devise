# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails_app_session',
  :secret      => '89e8147901a0d7c221ac130e0ded3eeab6dab4a97127255909f08fedaae371918b41dec9d4d75c5b27a55c3772d43c2b6a3cbac232c5cc2ce4b8ec22242f5e60'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
