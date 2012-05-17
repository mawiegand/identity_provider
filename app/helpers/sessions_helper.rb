module SessionsHelper
  
  # Checks whether the present visitor has authenticated himself properly
  # (that is, has successfully logged in using a valid identity) and
  # denies access otherwise.
  def authenticate 
    deny_access unless signed_in?
  end
  
  # Checks whether the present user has admin-status and redirects to 
  # sign-in otherwise.
  def authorize_admin
    deny_access I18n.translate('sessions.authorization.access_denied.admin') unless admin?
  end
  
  # Checks whether the present user has staff-status and redirects to
  # sign-in otherwise. Admin users always have staff-status.
  def authorize_staff
    deny_access I18n.translate('sessions.authorization.access_denied.staff') unless staff?
  end
  
  # Sign-in with the specified identity. Places a cookie for session tracking
  # and sets the current_identity to the given identity. The identity to sign-in
  # must have been authenticated (e.g. checked credentials) before hand.
  def sign_in(identity)
    cookies.permanent.signed[:remember_token] = [identity.id, identity.salt]
    self.current_identity = identity
  end
  
  # True, in case the present visitor has logged-in providing valid 
  # credentials of a registered identity. 
  def signed_in?
    !current_identity.nil?
  end
  
  # True, in case the present user is an admin user.
  def admin?
    !current_identity.nil? && current_identity.admin && request_authorization[:privileged]
  end
  
  # True, in case the present user is a staff memeber. Admins always have
  # staff status, even when their staff flag hasn't been set properly.
  def staff?
    admin? || (!current_identity.nil? && current_identity.staff && request_authorization[:privileged]) # admin is always staff
  end
  
  # Signs the present user out by destroying the cookie and unsetting
  # the current_identity .
  def sign_out
    cookies.delete(:remember_token)
    self.current_identity = nil
  end
  
  # Sets the current_identity to the given identity.
  def current_identity=(identity)
    @current_identity = identity
  end
  
  # Returns the current_identity in case the present visitor has logged-in. If
  # no identity has been set (e.g. because its the first call to this getter),
  # the method tries to get the identity from the rember token stored in the
  # visitor's cookie. If the remember token hasn't been set, the visitor hasn't
  # authenticated himself so far and thus, the method returns nil. 
  #
  # Thus, this method realizes the session tracking.
  def current_identity 
    raise BearerAuthInvalidRequest.new('Multiple access tokens sent within one request.') if !valid_authorization_header?
    @current_identity ||= identity_from_access_token || identity_from_remember_token # returns either the known identity or the one corresponding to the token
  end
  
  def identity_from_access_token
    raise BearerAuthInvalidRequest.new('Multiple access tokens sent within one request.') if !valid_authorization_header?
    return nil if request_access_token.nil?
    
    raise BearerAuthInvalidToken.new('Invalid or malformed access token.') unless request_access_token.valid? 
    raise BearerAuthInvalidToken.new('Access token expired.') if request_access_token.expired?
    raise BearerAuthInsufficientScope.new('Requested resource is not in authorized scope.') unless request_access_token.in_scope?('5dentity')
  
    identity = Identity.find_by_id_identifier_or_nickname(request_access_token.identifier, :deleted => false)
  end
  
  def request_access_token
    return @request_access_token unless @request_access_token.nil?
    if !request.headers['HTTP_AUTHORIZATION'].blank?
      chunks = request.headers['HTTP_AUTHORIZATION'].split(' ')
      logger.error 'HEADERS: ' + chunks.inspect
      logger.error request.headers['HTTP_AUTHORIZATION'].inspect
      raise BearerAuthInvalidRequest.new('Send bearer token in authorization header.') unless chunks.length == 2 && chunks[0].downcase == 'bearer'
      request_authorization[:method] = :header
      @request_access_token = FiveDAccessToken.new chunks[1]
    elsif params[:access_token]
      @request_access_token = FiveDAccessToken.new params[:access_token]
      if request.query_parameters[:access_token]
        request_authorization[:method] = :query   
      elsif request.request_parameters[:access_token]
        request_authorization[:method] = :request 
      else # e.g. extracted access_token from path
        raise BearerAuthInvalidRequest.new('Send access token in authorization header, query string or body (POST).')
      end
    else # no access token
      return nil
    end
    request_authorization[:grant_type] = :bearer
    request_authorization[:privileged] = false
    
    return @request_access_token
  end
  
  def request_authorization
    return @request_authorization ||= {}
  end
  
  # Returns the identity matching the remember token or nil, if it hasn't been
  # set or is not valid.
  def identity_from_remember_token
    identity = Identity.authenticate_with_salt(*remember_token)
    request_authorization[:grant_type] = :session
    request_authorization[:privileged] = true
    return identity
  end

  # Returns either the remember_token that has been set in the cookie
  # or a nil - array.
  def remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end
  
  # Method that should be called to block the user from accessing the 
  # requested page when he's not authorized to access it. The method
  # displays the given notice (using the flash) and redirects to the
  # sign-in form.
  def deny_access(notice = "You are not allowed to access this page. Please log in.")
    
    respond_to do |format|
      format.html {
        if ! signed_in?
          store_location
          redirect_to signin_path, :notice => notice
        else
          clear_return_to
          raise ForbiddenError.new "You have tried to access a resource you're not authorized to see. The incident has been logged."
        end
      }
      format.json {
        if ! signed_in?
          raise BearerAuthError.new "Authorization needed."
        else
          raise ForbiddenError.new "You have tried to access a resource you're not authorized to see. The incident has been logged."
        end        
      }
    end
  end
  
  # Redirects a user to the stored location, if stored, and to a 
  # default location otherwise. Is used for friendly redirecting
  # after signin.
  def redirect_back_or(default)
    redirect_to(stored_location || default)
    clear_return_to
  end
  
  def valid_authorization_header?
    return @valid_authorization_header unless @valid_authorization_header.nil?
 
    num_access_tokens = 0
    num_access_tokens+=1 if request.query_parameters[:access_token]
    num_access_tokens+=1 if request.request_parameters[:access_token]
    num_access_tokens+=1 if request.path_parameters[:access_token]
    num_access_tokens+=1 if request.headers['HTTP_AUTHORIZATION']
    logger.debug("params: #{ params[:access_token] } header: #{ request.headers['HTTP_AUTHORIZATION'] } query string: #{ request.query_string} num tokens: #{num_access_tokens}")
    
    @valid_authorization_header = num_access_tokens <= 1 # received either one or no access token
  end
  
  private
    
    def stored_location
      return session[:return_to]
    end
    
    def store_location
      session[:return_to] = request.fullpath
    end
    
    def clear_return_to
      session[:return_to] = nil
    end
  
end
