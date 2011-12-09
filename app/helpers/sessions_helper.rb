module SessionsHelper
  def sign_in(identity)
    cookies.permanent.signed[:remember_token] = [identity.id, identity.salt]
    self.current_identity = identity
  end
  
  def current_identity=(identity)
    @current_identity = identity
  end
end
