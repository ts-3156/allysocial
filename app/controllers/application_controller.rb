class ApplicationController < ActionController::Base
  around_action :switch_locale

  def switch_locale(&action)
    if (locale = params[:locale] || extract_locale_from_accept_language_header) && I18n.available_locales.map(&:to_s).include?(locale)
      I18n.with_locale(locale, &action)
    else
      I18n.with_locale(I18n.default_locale, &action)
    end
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  rescue => e
    I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
