# All Devise controllers are inherited from here.
class DeviseController < ApplicationController
  include Devise::Controllers::InternalHelpers
end
