# frozen_string_literal: true

class StreamingController < ApplicationController
  include ActionController::Live

  before_action :authenticate_user!

  def index
    render (Devise::Test.rails5_and_up? ? :body : :text) => 'Index'
  end
end
