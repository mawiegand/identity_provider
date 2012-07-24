class Resource::CharacterPropertiesController < ApplicationController
  # GET /resource/character_properties
  # GET /resource/character_properties.json
  
  before_filter :authenticate_service_or_backend, :only   => :index
  before_filter :authenticate,                    :except => :index

  before_filter :authorize_staff,                 :except => :index                         
  
  
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
    @resource_character_property = Resource::CharacterProperty.new(params[:resource_character_property])

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
