class ApplicationController < ActionController::Base
  before_action :set_locale

  def set_locale
    I18n.locale = I18n.available_locales.map(&:to_s).include?(params[:locale]) ? params[:locale] : I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
