# The IdentitiesController allows users to register (sign-up) 
# new identities, displays profiles of identities and allows
# staff members to browse a sorted list of all identities in
# the system.
class IdentitiesController < ApplicationController

  before_filter :authenticate,    :only => [:index]   # must be logged-in to see these pages
  before_filter :authorize_staff, :only => [:index]   # only staff can access these pages

  # display the profile of an individual identity
  def show
    @identity = Identity.find(params[:id]) || render_404
    @title = @identity.address_informal
    
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
    
    if @identity.save                                # created successfully
      logRegisterSuccess(@identity)                  # log creation
      IdentityMailer.validation_email(@identity).deliver # send email validation email
      sign_in @identity                              # sign in with newly created identity
      flash[:success] =    
        I18n.t('identities.signup.flash.welcome', :name => @identity.address_informal)
      redirect_to @identity                          # redirect to new identity
      
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
  
  # Special action for validating the email of an identity.
  # This action is called when visiting the validation link
  # sent in the validation email (during identity creation).
  # The action checks the validity of the validation token
  # sent with the request. It validates the identity only
  # once and sends an error message when called for an
  # already validated user or given an invalid token.
  def activation
    @identity = Identity.find(params[:id])    || render_404
    if @identity.nil?
      redirect_to new_identity_path, :notice => I18n.t('identities.validation.flash.user_not_found')
    else
      if @identity.activated.nil?   # not activated, yet?
        if @identity.has_validation_code?(params[:code])
          @identity.touch(:activated)
          redirect_to @identity, :notice => I18n.t('identities.validation.flash.validated')
        else
          logger.debug("Email validation for identity #{params[:id]} did fail because token do not match (sent / exepcted):\n#{params[:code]}\n#{@identity.validation_code}")
          redirect_to @identity, :notice => I18n.t('identities.validation.flash.wrong_token')  
        end        
      else
        redirect_to @identity, :notice => I18n.t('identities.validation.flash.already_validated')
      end
    end
  end
  
  private
    
    def logRegisterSuccess(identity)
      entry = LogEntry.new(:affected_table => 'identity',
                           :affected_id => identity.id,
                           :event_type => 'register_success',
                           :description => "Registered new user for #{identity.email} as #{ identity.address_informal } with id #{ identity.id }.");

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
