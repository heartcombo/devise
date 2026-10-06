# frozen_string_literal: true

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  around_action :set_locale
  before_action :current_user, unless: :devise_controller?
  before_action :authenticate_user!, if: :devise_controller?
  # Mime::SET is deprecated in favor of Mime.symbols, which older supported Rails versions lack.
  formats = Mime.respond_to?(:symbols) ? Mime.symbols : Mime::SET.map(&:to_sym)
  respond_to(*formats)

  devise_group :commenter, contains: [:user, :admin]

  private

  def set_locale
    I18n.with_locale(params[:locale] || I18n.default_locale) { yield }
  end

  def default_url_options
    {locale: params[:locale]}.compact
  end
end
