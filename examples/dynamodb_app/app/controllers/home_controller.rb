# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!, only: :dashboard

  def index
  end

  def dashboard
  end
end
