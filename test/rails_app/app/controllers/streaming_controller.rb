# frozen_string_literal: true

class StreamingController < ApplicationController
  include ActionController::Live

  before_action :authenticate_user!

  def index
    render (Devise::Test.rails5_and_up? ? :body : :text) => 'Index'
  end

  # Work around https://github.com/heartcombo/devise/issues/2332, which affects
  # tests in Rails 4.x (and affects production in Rails >= 5)
  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
