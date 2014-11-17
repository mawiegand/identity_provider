require 'active_support/secure_random'

# The IdentitiesController allows users to register (sign-up) 
# new identities, displays profiles of identities and allows
# staff members to browse a sorted list of all identities in
# the system.
class IdentitiesController < ApplicationController

  before_filter :authenticate,                     :except   => [:new, :show, :create, :update, :validation, :send_password_token, :send_password]   # these pages can be seen without logging-in
  before_filter :authorize_staff,                  :only     => [:index]                              # only staff can access these pages
  before_filter :authenticate_game_backend_or_api, :only     => [:update]                          
  
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
    @identity = Identity.find_by_id_identifier_or_nickname(params[:id], :find_deleted => staff?) # only staff can see deleted users
    raise NotFoundError.new('Page Not Found') if @identity.nil?
    
    # third: determine the role of the current user. 
    role = current_identity ? current_identity.role : (current_game ? :game : :default)
    role = :owner if !admin? && current_identity && current_identity.id == @identity.id # here :owner beats :staff

    # fourth: collect and sanitize values then render output (either html or JSON)
    respond_to do |format|
      format.json { 
        @attributes = @identity.sanitized_hash(role)           # only those, that may be read by present user

        logger.debug "-----> role #{role} #{@attributes}"

        @attributes[:gravatar_hash] = @identity.gravatar_hash
        render :json => include_root(@attributes.delete_if { |k,v| v.nil? }, :identity) # first compact the return string to non-blank attrs, then possible re-include the correct root (for RESTKIT access)
      }      
      format.html {
        @options = {
          :address_informal             => @identity.address_informal(role),
          :gravatar_url                 => @identity.gravatar_url(:size => 120),
          :messages_count               => (staff? ? @identity.received_messages.count : nil), 
          :show_edit_link               => [ :owner, :staff, :admin ].include?(role),
          :show_delete_link             => [ :owner, :staff, :admin ].include?(role),
          :show_delete_immediately_link => [ :admin ].include?(role),
          :lifetime                     => ([ :owner, :admin, :staff ].include?(role) ? @identity.lifetime : nil),
        }
        @devices    = staff? ? @identity.devices : nil
        @attributes = @identity.sanitized_hash(role)          # the easiest way to make sure, we don't display
                                                              # some attributes that should not be visible to
                                                              # the requesting user, is to only access the 
                                                              # sanitized hash in the view, that only contains
                                                              # the attributes visible to the given role. 
        @title = @options[:address_informal]                  # never forget to set this for the side-wide layout
      }
    end
  end
  
  def self
    logger.debug "Accessed self with access token in url / body #{ params[:access_token] } and current identity #{ current_identity }."
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
    agent       = request.env["HTTP_USER_AGENT"]
    referer     = request.env["HTTP_X_ALT_REFERER"]
    request_url = request.env["HTTP_X_ALT_REQUEST"]
        
    logger.debug "Trying to signup with user agent #{agent}, referer #{referer} and request url #{request_url}."
    
    LogEntry.create_signup_attempt(params, current_identity, request.remote_ip, agent, referer, request_url)

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
        
        # STEP ONE: create identity
        
        saved = false
        
        begin
          base_name = if !params[:nickname].blank? && !(params[:nickname] =~ /^[^\d\s]+[^\s]*$/i).nil?
            params[:nickname]
          else
            !params[:nickname_base ].blank? && !(params[:nickname_base] =~ /^[^\d\s]+[^\s]*$/i).nil? ? params[:nickname_base] : "WackyUser"
          end
          
          disambiguated_name = base_name
          
          # OPTIMIZE: the following is a very simple algorithm and should be replaced
          # at some point in time.
          while !Identity.find(:first, :conditions => [ "lower(nickname) = ?", disambiguated_name.downcase ]).nil?
            if i == 0 
              disambiguated_name = "#{ base_name }#{(Identity.count || 0)}"
            else
              disambiguated_name = "#{ base_name }#{((Identity.count || 0) + i).to_s}"
            end
            i = i+1
          end
          
          email = if !params[:email].blank?
            params[:email]
          elsif client.signup_without_email?
            "generic_#{(0...8).map{ ('a'..'z').to_a[rand(26)] }.join}_#{Identity.maximum(:id).to_i + 1}@5dlab.com"
          else
            nil
          end
          
          identity = Identity.new
          identity.nickname = disambiguated_name
          identity.email = email
          identity.locale = I18n.locale
          identity.referer = referer.blank? ? "none" : referer[0..250]
          identity.ref_id = params[:refid] || params[:ref_id] || nil
          identity.sub_id = params[:subid] || params[:sub_id] || nil
          identity.password = params[:password]
          identity.password_confirmation = params[:password_confirmation]
          identity.generic_nickname = params[:nickname].blank?
          identity.generic_email    = params[:email].blank?
          identity.generic_password = !params[:generic_password].blank? && !params[:generic_password].to_i.zero?
          identity.sign_up_with_client_id = client.id

          if !params[:gc_player_id].blank? && Identity.free_gc_player_id?(params[:gc_player_id]) 
            identity.connect_to_game_center(params[:gc_player_id])
          end
          
          if !identity.valid?
            logger.error "ERROR DURING SIGNUP: identity is invalid #{ identity.nickname }, #{ identity.identifier }, #{ identity.email }, #{ identity.password}==#{ identity.password_confirmation } with params #{ params.inspect }."
            logger.error "ERROR: validity of nickname #{ Identity.valid_nickname?(identity.nickname) }"
            raise BadRequestError.new(I18n.translate "error.identityInvalid")
          end
                  
          saved = identity.save          
        end while !identity.errors.messages[:nickname].nil?    # did save fail due to duplicate nickname? 
        
        # STEP TWO: now 'sign up' the identity to the client's scopes (that is, grant the corresponding scopes to the identity)
        
        if saved
          LogEntry.create_signup_success(params, identity, request.remote_ip)
          
          # try to signup the identity for the cient's scopes
          client.signup_existing_identity(identity, params[:invitation], referer, request_url)
          
          # have a look at the results; on waiting list or granted access?
          on_waiting_list = !client.waiting_list_entries.where(identity_id: identity.id).first.nil?
          granted_access  = !client.grants.where(identity_id: identity.id).first.nil?
          
          if granted_access || on_waiting_list
            render :status => :created, :json => identity.sanitized_hash(:owner).delete_if { |k,v| v.blank? }, :location => identity  
          else
            render json: {error: :error}, status: :error          
          end
          
        else
          LogEntry.create_signup_failure(params, current_identity, request.remote_ip)
                    
          render json: {error: :error}, status: :error          
        end
      }
      format.html {
        @identity = Identity.new(params[:identity], :as => :creator)

        @identity.referer = referer.blank? ? "none" : referer[0..250]      
      
        if @identity.save                                      # created successfully
          LogEntry.create_signup_success(params, @identity, request.remote_ip)
                        # log creation
          IdentityMailer.validation_email(@identity).deliver unless @identity.generic_email?  # send email validation email
          sign_in @identity                                    # sign in with newly created identity
          flash[:success] =    
            I18n.t('identities.signup.flash.welcome', :name => @identity.address_informal(:owner))
          redirect_to @identity                                # redirect to new identity
        else 
          LogEntry.create_signup_failure(params, current_identity, request.remote_ip)
          
          @title = I18n.t('identities.signup.title')
          render :new
        end
      }
    end
  end
  
  def signin
    raise BadRequestError.new('Client Identifier Missing') if params[:client_id].blank?

    @identity = Identity.find_by_id_identifier_or_nickname(params[:id])
    raise NotFoundError.new('Page Not Found') if @identity.nil? || (@identity.deleted && !staff?)  # only staff can see deleted users

    @client = Client.find_by_id(params[:client_id])
    raise BadRequestError.new('Unknown Client') if @client.nil?

    access_token = FiveDAccessToken.generate_access_token(@identity.identifier, @client.scopes)
    if !access_token || !access_token.valid? || access_token.expired?
      raise BadRequestError.new('Staff-to-client sign in: failed to create a valid access token.')
    end

    @parameters = {
      access_token: access_token,
      client_url: @client.direct_backend_login_url 
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
    if !admin? && current_identity && current_identity.id == @identity.id
      role = :owner 
    elsif game_signed_in?
      role = :game
    end
    
    deny_access("You're not allowed to edit identity %s." % params[:id]) unless role == :owner || role == :game || staff?
    
    if params[:identity].has_key?(:nickname)
      identity = Identity.find_by_nickname_case_insensitive(params[:identity][:nickname], find_deleted: true)
      raise ConflictError.new('Nickname already taken.')   if !identity.nil? && identity != @identity
    end
    
    if role == :game && params[:identity].has_key?(:nickname) && !(@identity.nickname.nil? || @identity.nickname.starts_with?('WackyUser'))
      params[:identity].delete(:nickname)
    end
    
    if params[:identity][:fb_rejected] && params[:identity][:fb_rejected].to_i == 1 && @identity.fb_rejected_at.nil?
      params[:identity][:fb_rejected_at] = DateTime.now
    elsif !params[:identity][:fb_rejected].nil? && params[:identity][:fb_rejected].to_i == 0 && Identity.accessible_attributes(role).include?(:fb_rejected_at)
      @identity.fb_rejected_at = nil
    end
    
    if params[:identity][:gc_rejected] && params[:identity][:gc_rejected].to_i == 1 && @identity.gc_rejected_at.nil?
      params[:identity][:gc_rejected_at] = DateTime.now
    elsif !params[:identity][:gc_rejected].nil? && params[:identity][:gc_rejected].to_i == 0 && Identity.accessible_attributes(role).include?(:gc_rejected_at)
      @identity.gc_rejected_at = nil
    end
    
    if params[:identity][:insider] && params[:identity][:insider].to_i == 1 && @identity.insider_since.nil?
      params[:identity][:insider_since] = DateTime.now
    elsif !params[:identity][:insider].nil? && params[:identity][:insider].to_i == 0 && Identity.accessible_attributes(role).include?(:insider_since)
      @identity.insider_since = nil
    end

    if params[:identity][:platinum_lifetime] && params[:identity][:platinum_lifetime].to_i == 1 && @identity.platinum_lifetime_since.nil?
      params[:identity][:platinum_lifetime_since] = DateTime.now
    elsif !params[:identity][:platinum_lifetime].nil? && params[:identity][:platinum_lifetime].to_i == 0 && Identity.accessible_attributes(role).include?(:platinum_lifetime_since)
      @identity.platinum_lifetime_since = nil
    end

    if params[:identity][:divine_supporter] && params[:identity][:divine_supporter].to_i == 1 && @identity.divine_supporter_since.nil?
      params[:identity][:divine_supporter_since] = DateTime.now
    elsif !params[:identity][:divine_supporter].nil? && params[:identity][:divine_supporter].to_i == 0 && Identity.accessible_attributes(role).include?(:divine_supporter_since)
      @identity.divine_supporter_since = nil
    end

    # assign everything, but handle email specifically
    @identity.assign_attributes params[:identity].delete_if { |k,v| v.nil? }.except(:email), :as => role      
    
    if params[:identity].has_key?(:email)
      # staff & admin may change every email, owner and game only generic emails (set email once and change never again)
      raise ForbiddenError.new('Write access to email forbidden.')  if !staff? && !((role == :game || role == :owner) && @identity.generic_email?)
      
      identity = Identity.where("lower(email) = lower(?) AND (deleted IS NULL OR NOT deleted)", params[:identity][:email]).first
      raise ConflictError.new('Email already taken.')      if !identity.nil? && identity != @identity
      
      @identity.email = params[:identity][:email]
      @identity.generic_email = false
    end
    
    if params[:identity].has_key?(:password)
      @identity.generic_password = false
    end
    
    if params[:identity].has_key?(:nickname) 
      @identity.generic_nickname = false
    end
        
    if @identity.save
      respond_to do |format|
        format.json { render json: {}, status: :ok }      
        format.html { redirect_to :action => "show" }
      end
    else
      respond_to do |format|
        format.json { render json: {}, status: :conflict }      
        format.html do
          flash[:error] = I18n.t('identities.update.flash.error', :name => @identity.address_informal)
          
          @sanitized_identity = @identity.sanitized_hash(role)
          @sanitized_identity[:gravatar_url] = @identity.gravatar_url :size => 120
          @sanitized_identity[:address_informal] = @identity.address_informal(role)
    
          @accessible_attributes = Identity.accessible_attributes(role) 
          
          render :action => "edit", :status => 500
        end
      end
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

    #identity = Identity.find_by_email(params[:identifier])
    #identity = Identity.find_by_nickname(params[:identifier]) if identity.nil?

    identity = Identity.where('lower(email) = ?', params[:identifier].downcase).first
    identity = Identity.where('lower(nickname) = ?', params[:identifier].downcase).first if identity.nil?

    if identity.nil?
      raise NotFoundError.new "Mail not found"
    elsif identity.generic_email?
      raise NotFoundError.new "No email address for this user."
    else
      # create password token      
      identity.password_token = identity.make_random_string(32)
      identity.save
  
      # send mail with token
      IdentityMailer.password_token_email(identity).deliver      
    end
      
    render :status => :ok, :json => {}                 
  end
  
  def send_password
    accessing_client = Client.find_by_id_or_identifier(params[:client_id])
    raise ForbiddenError.new "Access forbidden. Client id not found." if accessing_client.nil?
    raise ForbiddenError.new "Access forbidden. Wrong credentials."   if params[:client_password].nil? || params[:client_password] != accessing_client.password

    identity = Identity.find(params[:id])
    
    raise NotFoundError.new "No password token set" if identity.nil? || identity.password_token != params[:password_token] 

    # passwort erzeugen
    new_password = identity.make_random_string(8)
    identity.password = new_password
    identity.password_confirmation = new_password
    identity.password_token = nil
    identity.save

    # mail raushauen
    IdentityMailer.password_email(identity, new_password).deliver    # send waiting-list email
    
    render :status => :ok, :json => {}
  end
  
  private
  
    def name_blacklisted?(name)
      black_list = %w{index edit new admin staff user adolf hitler 5d service root owner}
      black_list.include? name.downcase
    end
    

end
