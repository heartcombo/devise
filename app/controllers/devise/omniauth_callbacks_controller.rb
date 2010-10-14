class Devise::OmniauthCallbacksController < ApplicationController
  include Devise::Controllers::InternalHelpers

  def failure
  end
end