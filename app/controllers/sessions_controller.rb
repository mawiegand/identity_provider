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
    else 
      logSigninSuccess(params[:session][:login], identity)
      sign_in identity
      redirect_to identity
    end
  end
  
  # Sings the user out by destroying the session.
  def destroy
    logSignout(current_identity)
    sign_out
    redirect_to new_session_path
  end
  
  
  private 

    # Logging  
    def logSignout(identity)
      LogEntry.create(:identity => identity,
                      :role => identity.role_string,
                      :affected_table => 'identity',
                      :affected_id => identity.id,
                      :event_type => 'signout_destroy',
                      :description => "User #{ !identity.nickname.nil? ? identity.nickname : identity.email } signed out.");
    end
  
    def logSigninFailure(email, as_identity)
      identity = Identity.find_by_email(email);
      entry = LogEntry.new(:affected_table => "identity",
                           :event_type => 'signin_failure');
      if !as_identity.nil?
        entry.identity = as_identity;
        entry.role = as_identity.role_string;
      else
        entry.role = 'none'
      end
      if !identity.nil?
        entry.affected_id = identity.id
      end
      entry.description = "Sign-in with email #{email}  (#{ identity.nil? || identity.nickname.nil? ? 'unknown user' : 'user ' + identity.nickname  }) did fail#{ as_identity.nil? ? '' : ' for current_user ' + (as_identity.nickname.nil ? as_identity.email : as_identity.email) }."
      entry.save
    end
  
    def logSigninSuccess(email, identity)
      entry = LogEntry.new(:identity => identity,
                           :role => identity.role_string,
                           :affected_table => 'identity',
                           :affected_id => identity.id,
                           :event_type => 'signin_success',
                           :description => "Sign-in with #{email} (user #{ identity.nickname }) did succeed.");
      entry.save
    end
    

end
