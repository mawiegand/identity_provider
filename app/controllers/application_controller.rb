class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper     # session helpers must be available to all controllers
  
  before_filter :set_locale  # get the locale from the user parameters
  
  # This method adds the locale to all rails-generated path, e.g. root_path.
  # Based on I18n documentation in rails guides:
  # http://guides.rubyonrails.org/i18n.html  
  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end
  
  protected
  
    # Set the locale according to the user specified locale or to the default
    # locale, if not specified or specified is not available.
    def set_locale
      I18n.locale = get_locale_from_params || I18n.default_locale
    end
    
    # Checks whether the user specified locale is available.
    def get_locale_from_params 
      return nil unless params[:locale]
      I18n.available_locales.include?(params[:locale].to_sym) ? params[:locale] : nil
    end
end
