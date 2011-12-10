class IdentitiesController < ApplicationController

  before_filter :authenticate, :only => [:index]

  def show
    @identity = Identity.find(params[:id])
    @title = @identity.name
    
    respond_to do |format|
      format.html
      format.json { render :json => @identity }
    end
  end
  
  def new
    @identity = Identity.new
    @title = 'Register'    
  end
  
  def create
    @identity = Identity.new(params[:identity])
    if @identity.save
      logRegisterSuccess(@identity)
      sign_in @identity
      flash[:success] = "Welcome #{@identity.name}!"
      redirect_to @identity
    else 
      logRegisterFailure(params[:identity][:email], params[:identity][:name])
      @title = "Register"
      render :new
    end
  end
  
  def index
    @identities = Identity.paginate(:page => params[:page], :per_page => 60).order('name ASC')
    @title = 'Identities'
  end
  
  private
    
    def authenticate 
      deny_access unless signed_in?
    end
    
    
    def logRegisterSuccess(identity)
      entry = LogEntry.new(:affected_table => 'identity',
                           :affected_id => identity.id,
                           :event_type => 'register_success',
                           :description => "Registered new user for #{identity.email} as #{ identity.name } with id #{ identity.id }.");

      if current_identity.nil? 
        entry.role = 'none'
      else
        entry.identity_id = current_identity.id
        entry.role = 'user'
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
        entry.role = 'user'
      end

      entry.save
    end

end
