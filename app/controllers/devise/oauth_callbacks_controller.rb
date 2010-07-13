class Devise::OauthCallbacksController < ApplicationController
  include Devise::Controllers::InternalHelpers
  include Devise::Oauth::Helpers
end
