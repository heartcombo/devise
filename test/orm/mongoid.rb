require 'mongoid/version'

Mongoid.configure do |config|
  config.load!('test/support/mongoid.yml')
  config.use_utc = true
  config.include_root_in_json = true
end

class ActiveSupport::TestCase
  setup do
    Mongoid.purge!
  end
end
