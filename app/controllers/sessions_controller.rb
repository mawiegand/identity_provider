class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    identity = Identity.authenticate(params[:session][:email],
                                     params[:session][:password])
    if identity.nil?
      logSigninFailure(params[:session][:email], current_identity)
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'
    else 
      logSigninSuccess(params[:session][:email], identity)
      sign_in identity
      redirect_to identity
    end
  end
  
  def destroy
    logSignout(current_identity)
    sign_out
    redirect_to new_session_path
  end
  
  def logSignout(identity)
    LogEntry.create(:identity => identity,
                    :role => 'user',
                    :affected_table => 'identity',
                    :affected_id => identity.id,
                    :type => 'login_destroy',
                    :description => "User #{ identity.name } signed out.");
  end
  
  
  # Logging
  
  private 
  
    def logSigninFailure(email, as_identity)
      identity = Identity.find_by_email(email);
      entry = LogEntry.new(:affected_table => "identity",
                           :type => 'login_success');
      if !as_identity.nil?
        entry.identity = as_identity;
        entry.role = "user";
      end
      if !identity.nil?
        entry.affected_id = identity.id
      end
      entry.description = "Sign-in with email #{email}  (#{ identity.nil? ? 'unknown user' : 'user ' + identity.name  }) did fail#{ as_identity.nil? ? '' : ' for current_user ' + as_identity.name }."
      entry.save
    end
  
    def logSigninSuccess(email, identity)
      entry = LogEntry.new(:identity => identity,
                           :role => 'user',
                           :affected_table => 'identity',
                           :affected_id => identity.id,
                           :type => 'login_failure',
                           :description => "Sign-in with #{email} (user #{ identity.name }) did succeed.");
      entry.save
    end

end