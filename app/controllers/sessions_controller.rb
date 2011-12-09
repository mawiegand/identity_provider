class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    identity = Identity.authenticate(params[:session][:email],
                                     params[:session][:password])
    if identity.nil?
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'
    else 
      sign_in identity
      redirect_to identity
    end
  end
  
  def destroy
  end

end
