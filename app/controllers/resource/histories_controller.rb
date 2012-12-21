class Resource::HistoriesController < ApplicationController
  
  before_filter :authenticate_game_or_backend,    :only   => [ :index, :create ]
  before_filter :authenticate,                    :except => [ :index, :create ]

  before_filter :authorize_staff,                 :except => [ :index, :create ]                         
  before_filter :deny_api,                        :except => [ :index, :create ]  
  
  # GET /resource/histories
  # GET /resource/histories.json
  def index
    if params.has_key?(:identity_id)
      # first: filter out bad requests (malformed addresses, black-listed ressources)
      #bad_request = (name_blacklisted?(params[:identity_id]) && !staff?) || !Identity.valid_user_identifier?(params[:identity_id])
      #raise BadRequestError.new('Bad Request for Identity %s' % params[:identity_id]) if bad_request

      # second: find (non-deleted) identity or fail with a 404 not found error
      identity = Identity.find_by_id_identifier_or_nickname(params[:identity_id], :find_deleted => staff?) # only staff can see deleted users
      raise NotFoundError.new('Page Not Found') if identity.nil?    
      if current_game.nil?
        @resource_histories = identity.events
      else
        @resource_histories = identity.events.where(:game_id => current_game.id)
      end
    else 
      @asked_for_index = true
    end

    respond_to do |format|
      format.html do
        if @resource_histories.nil?
          @resource_histories =  Resource::History.paginate(:order => "identity_id ASC", :page => params[:page], :per_page => 50)    
          @paginate = true   
        end 
      end
      format.json do
        raise ForbiddenError.new('Access Forbidden')        if @asked_for_index
        render json: @resource_histories 
      end
    end       
  end

  # GET /resource/histories/1
  # GET /resource/histories/1.json
  def show
    @resource_history = Resource::History.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_history }
    end
  end

  # GET /resource/histories/new
  # GET /resource/histories/new.json
  def new
    @resource_history = Resource::History.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_history }
    end
  end

  # GET /resource/histories/1/edit
  def edit
    @resource_history = Resource::History.find(params[:id])
  end

  # POST /resource/histories
  # POST /resource/histories.json
  def create
    raise BadRequestError.new "Malformed or missing data."   unless params.has_key?(:resource_history)
    
    @resource_history = Resource::History.new(params[:resource_history])
    
    if !current_game.nil?
      raise ForbiddenError.new "Access to character in different game forbidden."  if params[:resource_history].has_key?(:game_id) && params[:resource_history][:game_id] != current_game.id
      @resource_history.game_id = current_game.id
      
      @identity = Identity.find_by_id_identifier_or_nickname(params[:identity_id], :find_deleted => staff?)
      raise NotFoundError.new "Identity not found"           if @identity.nil?
      @resource_history.identity_id = @identity.id
    end
    
    raise BadRequestError.new "Game id missing"              if @resource_history.game_id.nil?
    raise BadRequestError.new "Identity id missing"          if @resource_history.identity_id.nil?

    respond_to do |format|
      if @resource_history.save
        format.html { redirect_to @resource_history, notice: 'History was successfully created.' }
        format.json { render json: @resource_history, status: :created, location: @resource_history }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resource/histories/1
  # PUT /resource/histories/1.json
  def update
    @resource_history = Resource::History.find(params[:id])

    respond_to do |format|
      if @resource_history.update_attributes(params[:resource_history])

        @resource_history.data                  = eval(@params[:data])                  unless @params[:data].blank?
        @resource_history.localized_description = eval(@params[:localized_description]) unless @params[:localized_description].blank?

        format.html { redirect_to @resource_history, notice: 'History was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource/histories/1
  # DELETE /resource/histories/1.json
  def destroy
    @resource_history = Resource::History.find(params[:id])
    @resource_history.destroy

    respond_to do |format|
      format.html { redirect_to resource_histories_url }
      format.json { head :ok }
    end
  end
end
