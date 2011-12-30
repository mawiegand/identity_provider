# The IdentitiesController allows users to register (sign-up) 
# new identities, displays profiles of identities and allows
# staff members to browse a sorted list of all identities in
# the system.
class IdentitiesController < ApplicationController

  before_filter :authenticate,    :except   => [:new, :show, :create]   # these pages can be seen withou logging-in
  before_filter :authorize_staff, :only     => [:index]                 # only staff can access these pages
    
  # display the profile of an individual identity
  def show
    identity = nil
    bad_request = (name_blacklisted?(params[:id]) && !staff?) || !Identity.valid_identifer?(params[:id])
    raise BadRequestError.new('Bad Request for Identity %s' % params[:id]) if bad_request

    identity = Identity.find_by_id_or_nickname(params[:id])
    raise NotFoundError.new('Page Not Found') if identity.nil? || (identity.deleted && !staff?)  # only staff can see deleted users
    
    role = current_identity ? current_identity.role : :default
    role = :owner if !admin? && current_identity && current_identity.id == identity.id
    
    @sanitized_identity = identity.sanitized_hash(role)
    @sanitized_identity[:address_informal] = identity.address_informal(role)
    
    respond_to do |format|
      format.html {
        @sanitized_identity[:gravatar_url]                 = identity.gravatar_url :size => 120
        @sanitized_identity[:show_edit_link]               = [ :owner, :staff, :admin ].include?(role)
        @sanitized_identity[:show_delete_link]             = [ :owner, :staff, :admin ].include?(role)
        @sanitized_identity[:show_delete_immediately_link] = [ :admin ].include?(role)

        @title = @sanitized_identity[:address_informal]
      }
      format.json { 
        @sanitized_identity[:gravatar_hash] = identity.gravatar_hash
        render :json => @sanitized_identity
      }
    end
  end
  
  # send the sign-up form
  def new
    @identity = Identity.new
    @title = I18n.t('identities.signup.title')    
  end
  
  # create a new identity from the posted form data
  def create
    @identity = Identity.new(params[:identity], :as => :creator)
    
    if @identity.save                                      # created successfully
      logRegisterSuccess(@identity)                        # log creation
      IdentityMailer.validation_email(@identity).deliver   # send email validation email
      sign_in @identity                                    # sign in with newly created identity
      flash[:success] =    
        I18n.t('identities.signup.flash.welcome', :name => @identity.address_informal(:owner))
      redirect_to @identity                                # redirect to new identity
    else 
      logRegisterFailure(params[:identity][:email], params[:identity][:nickname])
      @title = I18n.t('identities.signup.title')
      render :new
    end
  end
  
  # edit an existing user
  def edit
    @identity = nil
    bad_request = (name_blacklisted?(params[:id]) && !staff?) || !Identity.valid_identifer?(params[:id])
    raise BadRequestError.new('Bad Request for Identity %s' % params[:id]) if bad_request

    @identity = Identity.find_by_id_or_nickname(params[:id])
    raise NotFoundError.new('Page Not Found') if @identity.nil? || (@identity.deleted && !staff?)  # only staff can see deleted users
    
    role = current_identity ? current_identity.role : :default
    role = :owner if !admin? && current_identity && current_identity.id == @identity.id

    deny_access("You're not allowed to edit identity %s." % params[:id]) unless role == :owner || staff?  

    @sanitized_identity = @identity.sanitized_hash(role)
    @sanitized_identity[:gravatar_url] = @identity.gravatar_url :size => 120
    @sanitized_identity[:address_informal] = @identity.address_informal(role)

    @accessible_attributes = Identity.accessible_attributes(role)
    
    @title = I18n.t('identities.edit.title')    
  end
  
  def update
    @identity = nil
    bad_request = (name_blacklisted?(params[:id]) && !staff?) || !Identity.valid_identifer?(params[:id])
    raise BadRequestError.new('Bad Request for Identity %s' % params[:id]) if bad_request

    @identity = Identity.find_by_id_or_nickname(params[:id])
    raise NotFoundError.new('Page Not Found') if @identity.nil? || (@identity.deleted && !staff?)  # only staff can see deleted users
    
    role = current_identity ? current_identity.role : :default
    role = :owner if !admin? && current_identity && current_identity.id == @identity.id

    deny_access("You're not allowed to edit identity %s." % params[:id]) unless role == :owner || staff?  
              
    @identity.assign_attributes params[:identity].delete_if { |k,v| v.nil? }, :as => role
        
    if @identity.save
      redirect_to :action => "show"
    else
      flash[:error] = I18n.t('identities.update.flash.error', :name => @identity.address_informal)
      
      @sanitized_identity = @identity.sanitized_hash(role)
      @sanitized_identity[:gravatar_url] = @identity.gravatar_url :size => 120
      @sanitized_identity[:address_informal] = @identity.address_informal(role)

      @accessible_attributes = Identity.accessible_attributes(role) 
      
      render :action => "edit", :status => 500
    end
  end
  
  # disable an existing user
  def destroy
    if staff?
      @identity = Identity.find(params[:id])
    else
      if params[:id].to_i != current_identity.id
        flash[:error] = I18n.t('identities.delete.flash.error')
        @identity = Identity.find(params[:id])
        render :action => "show" and return      
      else
        @identity = current_identity
      end
    end
    
    @identity = Identity.find(params[:id])
    @identity.deleted = true
    @identity.save
    
    if params[:id].to_i != current_identity.id
      redirect_to :action => "index", :success => I18n.t('identities.delete.flash.success', :name => @identity.address_informal)
    else
      sign_out
      redirect_to root_path, :success => I18n.t('identities.delete.flash.success', :name => @identity.address_informal)
    end
  end
  
  # show a paginated list of all identities in the system
  def index
    role = current_identity ? current_identity.role : :default

    @identities = Identity.paginate(:page => params[:page], :per_page => 60)  # here also show deleted users! (index is staff only)
    
    @sanitized_identities = []
    
    @identities.each do |identity|
      sanitized_identity = identity.sanitized_hash(role)
      sanitized_identity[:address_informal] = identity.address_informal(role, false)
      sanitized_identity[:gravatar_url] = identity.gravatar_url :size => 30
      sanitized_identity[:role_string] = identity.role_string
      @sanitized_identities << sanitized_identity
    end
    
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
  
    def name_blacklisted?(name)
      black_list = %w{index edit new admin staff user adolf hitler}
      black_list.include? name.downcase
    end
    
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
