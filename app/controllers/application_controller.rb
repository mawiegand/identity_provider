require 'exception/http_exceptions'


class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper     # session helpers must be available to all controllers
  
  before_filter :set_locale  # get the locale from the user parameters
  around_filter :time_action
  
  rescue_from NotFoundError, BadRequestError, ForbiddenError, :with => :render_response_for_exception
  
  # This method adds the locale to all rails-generated path, e.g. root_path.
  # Based on I18n documentation in rails guides:
  # http://guides.rubyonrails.org/i18n.html  
  def default_url_options(options={})
    { :locale => I18n.locale }
  end
  
  protected
  
    def time_action
      started = Time.now
      yield
      elapsed = Time.now - started
      logger.debug("Executing #{controller_name}::#{action_name} took #{elapsed*1000}ms in real-time.")
    end
  
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
      
    def render_response_for_exception(exception)  
      logger.info("%s: '%s', for request '%s' from %s" % [exception.class, exception.message, request.url, request.remote_ip] )
      respond_to do |format|
        format.html {
          render_html_for_exception exception
        }
        format.json { 
          render_json_for_exception exception
        }
      end
    end
    
    def render_json_for_exception(exception)
      head :bad_request if exception.class == BadRequestError
      head :not_found if exception.class == NotFoundError
      head :forbidden if exception.class == ForbiddenError
    end
    
    def render_html_for_exception(exception)
      render :text => exception.message, :status => :bad_request if exception.class == BadRequestError
      render :text => exception.message, :status => :not_found if exception.class == NotFoundError
      render :text => exception.message, :status => :forbidden if exception.class == ForbiddenError
    end
      
    # renders a 404 error
    def render_404
      raise ActionController::RoutingError.new('Not Found')
    end
    
    def render_400
      raise ActionController::RoutingError.new('Bad Request')
    end

end
