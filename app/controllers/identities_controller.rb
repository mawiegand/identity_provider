# The IdentitiesController allows users to register (sign-up) 
# new identities, displays profiles of identities and allows
# staff members to browse a sorted list of all identities in
# the system.
class IdentitiesController < ApplicationController

  before_filter :authenticate,    :only => [:edit, :delete]   # must be logged-in to see these pages
  before_filter :authorize_staff, :only => [:index]   # only staff can access these pages

  # display the profile of an individual identity
  def show
    @identity = Identity.find_by_id_and_deleted(params[:id], false)
    @title = @identity.nickname
      
    # respond_to do |format|
      # format.html
      # format.json { render :json => @identity }
    # end
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
  
  # edit an existing user
  def edit
    if staff?
      @identity = Identity.find(params[:id])
    else
      if params[:id].to_i != current_identity.id
        redirect_to :action => "edit", :id => current_identity.id
      else
        @identity = current_identity
      end
    end
  end
  
  def update
    if staff?
      @identity = Identity.find(params[:id])
    else
      if params[:id].to_i != current_identity.id
        redirect_to :action => "edit", :id => current_identity.id, :error => I18n.t('identities.update.flash.error', :name => @identity.address_informal)
      else
        @identity = current_identity
      end
    end
    
    @identity.nickname = params[:identity][:nickname] unless params[:identity][:nickname].blank?
    @identity.firstname = params[:identity][:firstname] unless params[:identity][:firstname].blank?
    @identity.surname = params[:identity][:surname] unless params[:identity][:surname].blank?
    @identity.email = params[:identity][:email] unless params[:identity][:email].blank?

    # validation will not be executed, if confirmation is nil    
    if !params[:identity][:password].blank? || !params[:identity][:password_confirmation].blank?
      @identity.password = params[:identity][:password]
      @identity.password_confirmation = params[:identity][:password_confirmation]
    end
        
    if @identity.save
      redirect_to :action => "show"
    else
      flash[:error] = I18n.t('identities.update.flash.error', :name => @identity.address_informal)
      render :action => "edit"
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
        return render :action => "show"      
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
    @identities = Identity.where(:deleted => false).paginate(:page => params[:page], :per_page => 60)
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
