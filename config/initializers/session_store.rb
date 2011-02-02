# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_aox_session',
  :secret      => 'b4d157ff482475b193939a2f935cf74d08ee10448a8492ae3a8e27ab34094f8a38d8b7c01c0e4e23742e8ba604efd342d3be42008fc81257f7ba66453a4e6da6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
