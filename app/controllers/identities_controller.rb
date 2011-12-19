# The IdentitiesController allows users to register (sign-up) 
# new identities, displays profiles of identities and allows
# staff members to browse a sorted list of all identities in
# the system.
class IdentitiesController < ApplicationController

  before_filter :authenticate,    :only => [:index]   # must be logged-in to see these pages
  before_filter :authorize_staff, :only => [:index]   # only staff can access these pages

  # display the profile of an individual identity
  def show
    @identity = Identity.find(params[:id])
    @title = @identity.nickname
    
    respond_to do |format|
      format.html
      format.json { render :json => @identity }
    end
  end
  
  # send the sign-up form
  def new
    @identity = Identity.new
    @title = I18n.t('identities.signup.title')    
  end
  
  # create a new identity from the posted form data
  def create
    @identity = Identity.new(params[:identity])
    if @identity.save
      logRegisterSuccess(@identity)
      sign_in @identity
      flash[:success] = 
        I18n.t('identities.signup.flash.welcome', :name => @identity.address_informal)
      redirect_to @identity
    else 
      logRegisterFailure(params[:identity][:email], params[:identity][:nickname])
      @title = I18n.t('identities.signup.title')
      render :new
    end
  end
  
  # show a paginated list of all identities in the system
  def index
    @identities = Identity.paginate(:page => params[:page], :per_page => 60)
    @title = I18n.t('identities.index.title')
  end
  
  private
    
    def logRegisterSuccess(identity)
      entry = LogEntry.new(:affected_table => 'identity',
                           :affected_id => identity.id,
                           :event_type => 'register_success',
                           :description => "Registered new user for #{identity.email} as #{ identity.nickname } with id #{ identity.id }.");

      if current_identity.nil? 
        entry.role = 'none'
      else
        entry.identity_id = current_identity.id
        entry.role = current_identity.role_string
      end                     
      
      entry.save
    end
    
    def logRegisterFailure(email, name)
      entry = LogEntry.new(:affected_table => 'identity',
                           :event_type => 'register_failure',
                           :description => "Registering new user for #{email} as #{ name } did fail.");

      if current_identity.nil? 
        entry.role = 'none'
      else
        entry.identity_id = current_identity.id
        entry.role = current_identity.role_string
      end

      entry.save
    end

end
