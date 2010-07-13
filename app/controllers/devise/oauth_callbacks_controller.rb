class Devise::OauthCallbacksController < ApplicationController
  include Devise::Controllers::InternalHelpers
  include Devise::Oauth::InternalHelpers
end