class ApplicationController < ActionController::Base
  before_action :set_locale

  def set_locale
    session[:locale] = params[:locale] || session[:locale] || :en
    I18n.locale = session[:locale]
  end
end
