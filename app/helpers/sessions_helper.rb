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
    deny_access "The page you requested may only be accessed by admins." unless admin?
  end
  
  # Checks whether the present user has staff-status and redirects to
  # sign-in otherwise. Admin users always have staff-status.
  def authorize_staff
    deny_access "The page you requested may only be accessed by staff." unless staff?
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
    !current_identity.nil? && current_identity.admin
  end
  
  # True, in case the present user is a staff memeber. Admins always have
  # staff status, even when their staff flag hasn't been set properly.
  def staff?
    admin? || (!current_identity.nil? && current_identity.staff)  # admin is always staff
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
    @current_identity ||= identity_from_remember_token # returns either the known identity or the one corresponding to the token
  end
  
  # Returns the identity matching the remember token or nil, if it hasn't been
  # set or is not valid.
  def identity_from_remember_token
    Identity.authenticate_with_salt(*remember_token)
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
  def deny_access(notice = "You are not allowed to access this page.")
    redirect_to signin_path, :notice => notice
  end
  
end
