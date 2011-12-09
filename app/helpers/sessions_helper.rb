module SessionsHelper
  
  def sign_in(identity)
    cookies.permanent.signed[:remember_token] = [identity.id, identity.salt]
    self.current_identity = identity
  end
  
  def signed_in?
    !current_identity.nil?
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
