# frozen_string_literal: true

class StreamingController < ApplicationController
  include ActionController::Live

  before_action :authenticate_user!

  def index
    render body: 'Index'
  end
end
