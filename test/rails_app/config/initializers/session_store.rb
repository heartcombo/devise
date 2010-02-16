# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_rails_app_session',
  :secret => '0c31f123b2bd4424ac366a7976aaa0696f0c82337c4073a5816a3abc6553293ad14f70cf23acb391954a8ce8cf08aaca3fab21e7642aa52ea212aefa19b7439d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
