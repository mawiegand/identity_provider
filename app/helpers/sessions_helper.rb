module SessionsHelper
  
  def authenticate 
    
#    logger.debug("BASIC_AUTH: started,")   
#    authenticate_or_request_with_http_basic "wackadoo" do | username, password |
#      logger.debug("BASIC_AUTH: #{username} #{password},")
#      identity = Identity.find(username)
#      if (identity)
#        @current_identity = Identity.authenticate(identity.email, password)
#      end
#      logger.debug("BASIC_AUTH: #{@current_identity}")
#    end
    deny_access unless signed_in?
  end
  
  def authorize_admin
    if !admin?
      redirect_to signin_path, :notice => "The page you requested may only be accessed by admins."
    end
  end
  
  def authorize_staff
    if !staff?
      redirect_to signin_path, :notice => "The page you requested may only be accessed by staff."
    end
  end
  
  def sign_in(identity)
    cookies.permanent.signed[:remember_token] = [identity.id, identity.salt]
    self.current_identity = identity
  end
  
  def signed_in?
    !current_identity.nil?
  end
  
  def admin?
    !current_identity.nil? && current_identity.admin
  end
  
  def staff?
    admin? || (!current_identity.nil? && current_identity.staff)  # admin is always staff
  end
  
  def sign_out
    cookies.delete(:remember_token)
    self.current_identity = nil
  end
  
  def current_identity=(identity)
    @current_identity = identity
  end
  
  def current_identity 
    @current_identity ||= identity_from_remember_token # returns either the known identity or the one corresponding to the token
  end
  
  def identity_from_remember_token
    Identity.authenticate_with_salt(*remember_token)
  end
  
  def remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end
  
  def deny_access
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end
  
end
