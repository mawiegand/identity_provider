# The SessionsController creates, tracks (by its helpers) and 
# and finally destroys a session for an authenticated user. 
#
class SessionsController < ApplicationController
    
  # Display a sign-in form
  def new
    @title = I18n.translate('sessions.signin.title')
  end
  
  # Receives user credentials via post and creates a session,
  # if the provided credentials could be verified.
  def create
    identity = Identity.authenticate(params[:session][:login],
                                     params[:session][:password])
                                     
    if identity.nil?
      logSigninFailure(params[:session][:login], current_identity)
      flash.now[:error] = I18n.translate('sessions.signin.flash.invalid')
      @title = I18n.translate('sessions.signin.title')
      render 'new'
    elsif identity.banned?
      logSigninFailure(params[:session][:login], current_identity)
      @title = I18n.translate('sessions.signin.title')
      flash.now[:error] = 'Der Account ist gesperrt.'   #I18n.translate('sessions.signin.flash.invalid')
      render 'new'
    else
      logSigninSuccess(params[:session][:login], identity)
      sign_in identity
      redirect_back_or (staff? ? dashboard_path : identity)
    end
  end
  
  # Signs the user out by destroying the session.
  def destroy
    logSignout(current_identity)
    sign_out
    redirect_to new_session_path
  end
  
  
  private 

    # Logging  
    def logSignout(identity)
      return LogEntry.create_signout(identity, request.remote_ip)
    end
  
    def logSigninFailure(email, as_identity)
      return LogEntry.create_signin_failure(email, as_identity, request.remote_ip)
    end
  
    def logSigninSuccess(email, identity)
      return LogEntry.create_signin_success(email, identity, request.remote_ip)
    end
    

end
