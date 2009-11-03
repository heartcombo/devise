begin
  require 'warden'
rescue
  gem 'warden'
  require 'warden'
end

# Session Serialization in. This block determines how the user will be stored
# in the session. If you're using a complex object like an ActiveRecord model,
# it is not a good idea to store the complete object. An ID is sufficient.
Warden::Manager.serialize_into_session{ |user| [user.class, user.id] }

# Session Serialization out. This block gets the user out of the session.
# It should be the reverse of serializing the object into the session
Warden::Manager.serialize_from_session do |klass, id|
  klass.find(id)
end

# Setup devise strategies for Warden
require 'devise/strategies/base'
