class FacebookController < ApplicationController

  before_filter :authenticate_game_backend_or_api, :except  => [ :show ]                            
  before_filter :deny_website, :except                      => [ :show ]                      
  
  
  # look-up an existing identity by the given gc_player_id and either return 200 - ok  or 404 - not found.
  # does not include any data about the identity in order to not give away any information that could
  # be used in fraud attempts
  def show
    raise ForbiddenError.new ("Access Forbidden.")                                        if !api_request? && !staff?
    raise BadRequestError.new ("missing facebook id")                                     if params[:id].blank?
    @identity = Identity.find_by_fb_player_id(params[:id]) 
    raise NotFoundError.new ("Not Found.")    if @identity.nil?                           # emit a not found error
    
    respond_to do |format|
      format.html { redirect_to @identity }
      format.json { render :json => {} }                                                  # just send an ok
    end
  end
  
  # connects a fb_player_id to an existing identity
  def update
    raise ForbiddenError.new  ("access forbidden")                                        if current_identity.nil? && current_game.nil?
    raise BadRequestError.new ("missing fb_player_id")                                    if params[:id].blank?
    raise BadRequestError.new ("missing access token")                                    if current_identity.nil? && params[:facebook].nil? || params[:facebook][:access_token].blank?
    raise BadRequestError.new ("missing identity_id")                                     if current_identity.nil? && params[:identity_id].nil?
    
    identity = current_identity || Identity.find_by_id_identifier_or_nickname(params[:identity_id])
    raise NotFoundError.new ('identity not found')                                        if identity.nil?
    
    raise ConflictError.new   ("id already taken")                                        if !Identity.find_by_fb_player_id(params[:id]).nil?
    raise ForbiddenError.new  ("identity is already connected to another fb_player_id")   if !identity.fb_player_id.blank?
    
    if !identity.connect_to_facebook(params[:id]).save
      raise BadRequestError.new ("could not connect identity to given facebook_id")
    end
    
    respond_to do |format|
      format.json {
        render :status => :ok, :json => {}, :location => current_identity  
      }
      format.html {
        redirect_to current_identity
      }
    end
  end
  
end
