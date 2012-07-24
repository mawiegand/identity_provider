class Resource::CharacterPropertiesController < ApplicationController
  # GET /resource/character_properties
  # GET /resource/character_properties.json
  
  before_filter :authenticate_game_or_backend,    :only   => [ :index, :update, :create ]
  before_filter :authenticate,                    :except => [ :index, :update, :create ]

  before_filter :authorize_staff,                 :except => [ :index, :update, :create ]                         
  
  def index
    if params.has_key?(:identity_id)
      # first: filter out bad requests (malformed addresses, black-listed ressources)
      #bad_request = (name_blacklisted?(params[:identity_id]) && !staff?) || !Identity.valid_user_identifier?(params[:identity_id])
      #raise BadRequestError.new('Bad Request for Identity %s' % params[:identity_id]) if bad_request

      # second: find (non-deleted) identity or fail with a 404 not found error
      identity = Identity.find_by_id_identifier_or_nickname(params[:identity_id], :find_deleted => staff?) # only staff can see deleted users
      raise NotFoundError.new('Page Not Found') if identity.nil?    
      if current_game.nil?
        @resource_character_properties = identity.character_properties
      else
        property = identity.character_properties.where(:game_id => current_game.id).first
        @resource_character_properties = property.nil? ? [] : [property]
      end
    else 
      @asked_for_index = true
    end

    respond_to do |format|
      format.html do
        if @resource_character_properties.nil?
          @resource_character_properties =  Resource::CharacterProperty.paginate(:order => "identity_id ASC", :page => params[:page], :per_page => 50)    
          @paginate = true   
        end 
      end
      format.json do
        raise ForbiddenError.new('Access Forbidden')        if @asked_for_index
        render json: @resource_character_properties 
      end
    end
  end

  # GET /resource/character_properties/1
  # GET /resource/character_properties/1.json
  def show
    @resource_character_property = Resource::CharacterProperty.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_character_property }
    end
  end

  # GET /resource/character_properties/new
  # GET /resource/character_properties/new.json
  def new
    @resource_character_property = Resource::CharacterProperty.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_character_property }
    end
  end

  # GET /resource/character_properties/1/edit
  def edit
    @resource_character_property = Resource::CharacterProperty.find(params[:id])
  end

  # POST /resource/character_properties
  # POST /resource/character_properties.json
  def create
    raise BadRequestError.new "Malformed or missing data."   unless params.has_key?(:resource_character_property)
    
    @resource_character_property = Resource::CharacterProperty.new(params[:resource_character_property])
    
    if !current_game.nil?
      raise ForbiddenError.new "Access to character in different game forbidden."  if params[:resource_character_property].has_key?(:game_id) && params[:resource_character_property][:game_id] != current_game.id
      @resource_character_property.game_id = current_game.id
    end
    
    raise BadRequestError.new "Game id missing"              if @resource_character_property.game_id.nil?
    raise BadRequestError.new "Identity id missing"          if @resource_character_property.identity_id.nil?

    old_entry = Resource::CharacterProperty.find_by_identity_id_and_game_id(@resource_character_property.identity_id, @resource_character_property.game_id)
    raise ConflictError.new "Already have properties for this player and game."  unless old_entry.nil?

    respond_to do |format|
      if @resource_character_property.save
        format.html { redirect_to @resource_character_property, notice: 'Character property was successfully created.' }
        format.json { render json: @resource_character_property, status: :created, location: @resource_character_property }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_character_property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resource/character_properties/1
  # PUT /resource/character_properties/1.json
  def update
    @resource_character_property = Resource::CharacterProperty.find(params[:id])

    if !current_game.nil?
      raise BadRequestError.new "Malformed or missing data."                        unless params.has_key?(:resource_character_property)

      raise ForbiddenError.new  "Access to character in different game forbidden."  if @resource_character_property.game_id != current_game.id
      raise BadRequestError.new "Forbidden to change game id"                       if params[:resource_character_property].has_key?(:game_id)     && params[:resource_character_property][:game_id]     != current_game.id
      raise BadRequestError.new "Forbidden to change identity id"                   if params[:resource_character_property].has_key?(:identity_id) && params[:resource_character_property][:identity_id] != resource_character_property.identity_id
    end
    
    respond_to do |format|
      if @resource_character_property.update_attributes(params[:resource_character_property])
        format.html { redirect_to @resource_character_property, notice: 'Character property was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_character_property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource/character_properties/1
  # DELETE /resource/character_properties/1.json
  def destroy
    @resource_character_property = Resource::CharacterProperty.find(params[:id])
    @resource_character_property.destroy

    respond_to do |format|
      format.html { redirect_to resource_character_properties_url }
      format.json { head :ok }
    end
  end
end
