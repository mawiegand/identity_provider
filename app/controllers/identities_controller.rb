require 'active_support/secure_random'

# The IdentitiesController allows users to register (sign-up) 
# new identities, displays profiles of identities and allows
# staff members to browse a sorted list of all identities in
# the system.
class IdentitiesController < ApplicationController

  before_filter :authenticate,    :except   => [:new, :show, :create, :validation, :send_password_token, :send_password]   # these pages can be seen without logging-in
  before_filter :authorize_staff, :only     => [:index]                              # only staff can access these pages
  
  # Returns a representation of a single identity-resource by either rendering 
  # a html page or sending a JSON-representation. 
  #
  # The reosource to be shown can be either addressed by a positive integer
  # or by a valid nickname string (does not start with a number, no spaces),
  # thus
  #  /identities/1
  # and
  #  /identities/Egbert
  # may both be valid URIs. The lookup of the identity corresponding nickname
  # is case-insensitive.
  #
  # == Authorization
  # Where in principle everybody may request every identity in the system, 
  # only specific roles may see some attribute values. Thus, attributes are 
  # internally sanitized against the read access set in the model for the 
  # current_identitie's role. Furthermore, the method does not allow access 
  # to identities marked as deleted or having a black-listed nickname, as long 
  # as the requesting identities does not have staff or higher authorization. 
  #
  # == Errors
  # If the request used a string to address the resssource that is not either
  # a positive integer or a "valid" nickname string, the action throws a 
  # +BadRequestError+. The same hapens when the ressource was addressed with
  # a valid name string that has been blacklisted (as long as not requested
  # by a staff member or admin)
  #
  # If no matching identity could be found ()
  def show
    # first: filter out bad requests (malformed addresses, black-listed ressources)
    bad_request = (name_blacklisted?(params[:id]) && !staff?) || !Identity.valid_user_identifier?(params[:id])
    raise BadRequestError.new('Bad Request for Identity %s' % params[:id]) if bad_request

    # second: find (non-deleted) identity or fail with a 404 not found error
    identity = Identity.find_by_id_identifier_or_nickname(params[:id], :find_deleted => staff?) # only staff can see deleted users
    raise NotFoundError.new('Page Not Found') if identity.nil?
    
    # third: determine the role of the current user. 
    role = current_identity ? current_identity.role : :default
    role = :owner if !admin? && current_identity && current_identity.id == identity.id # here :owner beats :staff
        
    # fourth: collect and sanitize values then render output (either html or JSON)
    respond_to do |format|
      format.json { 
        @attributes = identity.sanitized_hash(role)           # only those, that may be read by present user
        @attributes[:gravatar_hash] = identity.gravatar_hash
        render :json => @attributes.delete_if { |k,v| v.blank? } # to compact the return string to non-blank attrs
      }      
      format.html {
        @options = {
          :address_informal             => identity.address_informal(role),
          :gravatar_url                 => identity.gravatar_url(:size => 120),
          :show_edit_link               => [ :owner, :staff, :admin ].include?(role),
          :show_delete_link             => [ :owner, :staff, :admin ].include?(role),
          :show_delete_immediately_link => [ :admin ].include?(role)
        }
        @attributes = identity.sanitized_hash(role)           # the easiest way to make sure, we don't display
                                                              # some attributes that should not be visible to
                                                              # the requesting user, is to only access the 
                                                              # sanitized hash in the view, that only contains
                                                              # the attributes visible to the given role. 
        @title = @options[:address_informal]                  # never forget to set this for the side-wide layout
      }

    end
  end
  
  def self
    # this is to handle a bug in Safari (and other browsers), that lose a custom Authorization header when following a redirect
    if !params[:access_token].blank? && request_authorization && request_authorization[:method] != :header  # if a_t was in body (POST) or query (GET), append it as argument 
      redirect_to polymorphic_path(current_identity, :access_token => params[:access_token])
    else
      redirect_to current_identity
    end
  end
  
  # send the sign-up form
  def new
    @identity = Identity.new
    @title = I18n.t('identities.signup.title')    
  end
  
  # create a new identity from the posted form data
  def create
    respond_to do |format|
      format.json {
        client = Client.find_by_identifier(params[:client_id])
        email = params[:email].blank? ? nil : params[:email].downcase
        raise BadRequestError.new("No valid client") if client.nil?
        raise BadRequestError.new("Client's scope not valid")             if not client.scopes.include?('5dentity')
        raise BadRequestError.new("Client's secret not valid")            if params[:client_password] != client.password
        raise ConflictError.new(I18n.translate "error.emailTaken")        if email && Identity.find_by_email(email)
        raise BadRequestError.new(I18n.translate "error.passwordToShort") if !params[:password].blank? && params[:password].length < 6
        i = 0
        begin
          base_name = params[:nickname_base ].blank? ? "User" : params[:nickname_base]
          disambiguated_name = base_name
          
          # TODO: the following is the most simple algorithm and must be replaced
          # before there's noteworthy traffic on the server!!!!
          while !(Identity.find_by_nickname(disambiguated_name)).nil?
            i = i+1
            disambiguated_name = base_name + i.to_s
          end
          
          identity = Identity.new
          identity.nickname = disambiguated_name
          identity.email = params[:email]
          identity.password = params[:password]
          identity.password_confirmation = params[:password_confirmation]
          identity.sign_up_with_client_id = client.id
          
          raise BadRequestError.new(I18n.translate "error.identityInvalid") unless identity.valid?
                    
          saved = identity.save          
        end while !identity.errors.messages[:nickname].nil?    # did save fail due to duplicate nickname? 
        
        if saved
          # now grant scopes according to present sign_up_mode 
          if client.signup_mode == Client::SIGNUP_MODE_NORMAL      # normal mode -> always grant all scopes.
            identity.grants.create({
              client_id: client.id,
              scopes:    client.scopes
            });
            IdentityMailer.validation_email(identity).deliver      # send email validation email
            render :status => :created, :json => identity.sanitized_hash(:owner).delete_if { |k,v| v.blank? }, :location => identity     
          elsif client.signup_mode == Client::SIGNUP_MODE_INVITATION    # invitation mode -> grant scopes, if identity has a valid invitation
            if !params[:invitation].nil?
              invitation = client.keys.where(key: params[:invitation]).first
              if !invitation.nil? && invitation.num_used < invitation.number
                identity.grants.create({
                  client_id: client.id,
                  scopes:    client.scopes,
                  key_id:    invitation.id,
                })
                invitation.increment(:num_used)
                invitation.save
                IdentityMailer.validation_email(identity).deliver  # send email validation email
              else 
                # hack: backend activation button missing -> don't put them on the waiting list for manual activation
                
                identity.destroy
                raise BadRequestError.new "Die mit dieser Einladung verbundenen Slots wurden bereits restlos verbraucht."
                
                # hack end
                IdentityMailer.waiting_list_email(identity, params[:invitation]).deliver# send waiting-list email
              end
            else
              IdentityMailer.waiting_list_email(identity).deliver  # send waiting-list email
            end
            render :status => :created, :json => identity.sanitized_hash(:owner).delete_if { |k,v| v.blank? }, :location => identity     
          else # sign up mode off
            IdentityMailer.waiting_list_email(identity).deliver    # send waiting-list email
            render :status => :created, :json => identity.sanitized_hash(:owner).delete_if { |k,v| v.blank? }, :location => identity                 
          end
        else
          render json: {error: :error}, status: :error          
        end
      }
      format.html {
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
      }
    end
  end
  
  def signin
    raise BadRequestError.new('Client Identifier Missing') if params[:client].blank?

    @identity = Identity.find_by_id_identifier_or_nickname(params[:id])
    raise NotFoundError.new('Page Not Found') if @identity.nil? || (@identity.deleted && !staff?)  # only staff can see deleted users

    @client = Client.find_by_identifier(params[:client])
    raise BadRequestError.new('Unknown Client') if @client.nil?

    access_token = FiveDAccessToken.generate_access_token(@identity.identifier, @client.scopes)
    if !access_token || !access_token.valid? || access_token.expired?
      raise BadRequestError.new('Staff-to-client sign in: failed to create a valid access token.')
    end

    @parameters = {
      access_token: access_token,
      client_url: params[:client] == "WACKADOOHTML5" ? "URL" : "", # TODO: make dynamic 
    }
  end

  
  # edit an existing user
  def edit
    @identity = nil
    bad_request = (name_blacklisted?(params[:id]) && !staff?) || !Identity.valid_user_identifier?(params[:id])
    raise BadRequestError.new('Bad Request for Identity %s' % params[:id]) if bad_request

    @identity = Identity.find_by_id_identifier_or_nickname(params[:id])
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
    bad_request = (name_blacklisted?(params[:id]) && !staff?) || !Identity.valid_user_identifier?(params[:id])
    raise BadRequestError.new('Bad Request for Identity %s' % params[:id]) if bad_request

    @identity = Identity.find_by_id_identifier_or_nickname(params[:id])
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
  def validation
    @identity = Identity.find(params[:id])    || render_404
    if @identity.nil?
      redirect_to new_identity_path, :notice => I18n.t('identities.validation.flash.user_not_found')
    else
      if @identity.activated.nil?   # not activated, yet?
        if @identity.has_validation_code?(params[:code])
          @identity.touch(:activated)
          redirect_to IDENTITY_PROVIDER_CONFIG['redirect_after_activation'] # @identity, :notice => I18n.t('identities.validation.flash.validated')
        else
          logger.debug("Email validation for identity #{params[:id]} did fail because token do not match (sent / exepcted):\n#{params[:code]}\n#{@identity.validation_code}")
          redirect_to IDENTITY_PROVIDER_CONFIG['redirect_after_activation'] #@identity, :notice => I18n.t('identities.validation.flash.wrong_token')  
        end        
      else
        redirect_to IDENTITY_PROVIDER_CONFIG['redirect_after_activation'] #  @identity, :notice => I18n.t('identities.validation.flash.already_validated')
      end
    end
  end
  
  def send_password_token
    accessing_client = Client.find_by_id_or_identifier(params[:client_id])
    raise ForbiddenError.new "Access forbidden. Client id not found." if accessing_client.nil?
    raise ForbiddenError.new "Access forbidden. Wrong credentials."   if params[:client_password].nil? || params[:client_password] != accessing_client.password
    
    respond_to do |format|
      format.json { 
        render :status => :ok, :json => {}
      }      
      format.html {}
    end    



    # token erzeugen
    # in db eintragen
    # mail raushauen
  end
  
  def send_password
    # if token
    # passwort erzeugen
    # in db eintragen
    # token löschen
    # mail raushauen
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
