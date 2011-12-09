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
      sign_in @identity
      flash[:success] = "Welcome #{@identity.name}!"
      redirect_to @identity
    else 
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

end
