require 'exception/http_exceptions'
require 'five_d_access_token'


class ApplicationController < ActionController::Base
  #protect_from_forgery
  include SessionsHelper     # session helpers must be available to all controllers
  
  before_filter :set_locale  # get the locale from the user parameters
  around_filter :time_action
  after_filter { |controller|    
    logger.debug("Response headers: #{controller.response.headers}")
  }
  
  rescue_from NotFoundError, BadRequestError, ForbiddenError, ConflictError, NameError, :with => :render_response_for_exception
  rescue_from BearerAuthError, :with => :render_response_for_bearer_auth_exception
  
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
      logger.warn("%s: '%s', for request '%s' from %s" % [exception.class, exception.message, request.url, request.remote_ip] )
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
      render :json => { error_description: "Internal Server Error. Please contact support." }, :status => :internal_server_error       if exception.class  == NameError
      render :json => { error_description: exception.message }, :status => :bad_request                 if exception.class  == BadRequestError
      render :json => { error_description: exception.message }, :status => :not_found                   if exception.class  == NotFoundError
      render :json => { error_description: exception.message }, :status => :forbidden                   if exception.class  == ForbiddenError
      render :json => { error_description: exception.message }, :status => :conflict                    if exception.class  == ConflictError
    end
    
    def render_html_for_exception(exception)
      render :text => "Internal Server Error. Please contact support.", :status => :internal_server_error       if exception.class  == NameError
      render :text => exception.message, :status => :bad_request if exception.class == BadRequestError
      render :text => exception.message, :status => :not_found   if exception.class == NotFoundError
      render :text => exception.message, :status => :forbidden   if exception.class == ForbiddenError
      render :text => exception.message, :status => :conflict    if exception.class == ConflictError
    end
    
    # hanlde exceptions raised by a failed attempt to authorize with a bearer 
    # token of the resource and produce correct repsonses and headers. 
    def render_response_for_bearer_auth_exception(exception)
      info =   { :code => :bad_request }   # no description for unknwon (new or mislead) exception
      if exception.kind_of? BearerAuthInvalidRequest
        info = { :code => :bad_request,  :headers => { 'WWW-Authenticate' => 'Bearer realm="5dentity", error="invalid_request", error_description ="'+exception.message+'"' } }
      elsif exception.kind_of?(BearerAuthInvalidToken) 
        info = { :code => :unauthorized, :headers => { 'WWW-Authenticate' => 'Bearer realm="5dentity", error="invalid_token", error_description ="'+exception.message+'"' } }
      elsif exception.kind_of? BearerAuthInsufficientScope
        info = { :code => :forbidden,    :headers => { 'WWW-Authenticate' => 'Bearer realm="5dentity", error="insufficient_scope", error_description ="'+exception.message+'"' } }
      elsif exception.instance_of?(BearerAuthError)
        info = { :code => :unauthorized, :headers => { 'WWW-Authenticate' => 'Bearer realm="5dentity"' } }  # no error_code! (due to specs)
      end
      
      if info[:headers]
        info[:headers].each do |key, value|
          headers[key] = value
        end
      end

      respond_to do |format|
        format.html {
          render :text => exception.message, :status => info[:code]
        }
        format.json {
          head info[:code]
        }
      end
    end
      
    # renders a 404 error
    def render_404
      raise ActionController::RoutingError.new('Not Found')
    end
    
    def render_400
      raise ActionController::RoutingError.new('Bad Request')
    end

end
