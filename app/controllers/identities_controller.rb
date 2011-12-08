class IdentitiesController < ApplicationController

  def show
    @identity = Identity.find(params[:id])
    @title = @identity.name
  end
  
  def new
    @identity = Identity.new
    @title = 'Register'    
  end
  
  def create
    @identity = Identity.new(params[:identity])
    if @identity.save
      redirect_to @identity
    else 
      @title = "Register"
      render :new
    end
  end
  
  def index
    @identities = Identity.all
    @title = 'Identities'
  end

end
