# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gitosis-web-admin_session',
  :secret      => 'e5d25f284601c64e37cf4bedf4e1a3c23aec12712f7513b06811eab818022249e69a5924728ed4ff8ac29d979dac974e3133787cf118419842c9b3da73b61021'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
