class GameCenterController < ApplicationController
  
  before_filter :authenticate  
  before_filter :deny_backend, :except => [ :show ]                      
  
  # look-up an existing identity by the given gc_player_id and either return 200 - ok  or 404 - not found.
  # does not include any data about the identity in order to not give away any information that could
  # be used in fraud attempts
  def show
    raise BadRequestError.new ("missing gc_player_id")  if params[:id].blank?
    @identity = Identity.find_by_gc_player_id(params[:id]) 
    raise NotFoundError.new ("Not Found.")    if @identity.nil?  # emit a not found error
    
    respond_to do |format|
      format.html { redirect_to @identity }
      format.json { render :json => {} }                                   # just send an ok
    end
  end
  
  # connects a gc_player_id to an existing identity
  def create
    raise ForbiddenError.new  ("must be signed-in")     if current_identity.nil?
    raise BadRequestError.new ("missing gc_player_id")  if params[:id].blank?
    raise ConflictError.new   ("id already taken")      if !Identity.find_by_gc_player_id(params[:id]).nil?
    raise ForbiddenError.new  ("identity is already connected to another gc_player_id")   if !current_identity.gc_player_id.blank?
    
    if !identity.connect_to_game_center(params[:id]).save
      raise BadRequestError.new ("could not connect identity to given game_center_id")
    end
    
    respond_to do |format|
      format.json {
        render :status => :created, :json => {}, :location => identity  
      }
      format.html {
        redirect_to current_identity
      }
    end
  end
  
end
