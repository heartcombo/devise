module Devise
  class Delegator
    def call(env)
      Devise::FailureApp.call(env)
    end
  end
end