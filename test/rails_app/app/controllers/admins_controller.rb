# frozen_string_literal: true

class AdminsController < ApplicationController
  around_action :set_locale
  before_action :authenticate_admin!

  def index
  end

  private

  def set_locale
    I18n.with_locale(params[:locale] || I18n.default_locale) { yield }
  end
end
