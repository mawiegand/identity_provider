class Resource::HistoriesController < ApplicationController
  
  before_filter :authenticate_game_or_backend,    :only   => [ :index, :create ]
  before_filter :authenticate,                    :except => [ :index, :create ]

  before_filter :authorize_staff,                 :except => [ :index, :create ]                         
  before_filter :deny_api,                        :except => [ :index, :create ]  
  
  # GET /resource/histories
  # GET /resource/histories.json
  def index
    if params.has_key?(:identity_id)
      identity = Identity.find_by_id_identifier_or_nickname(params[:identity_id], :find_deleted => staff?) # only staff can see deleted users
      raise NotFoundError.new('Page Not Found') if identity.nil?    
      if current_game.nil?
        @histories = identity.events
      else
        @histories = identity.events.where(:game_id => current_game.id)
      end
    else
      @asked_for_index = true
    end

    respond_to do |format|
      format.html do
        if @resource_histories.nil?
          @histories =  Resource::History.paginate(:order => "identity_id ASC", :page => params[:page], :per_page => 50)    
          @paginate = true   
        end 
      end
      format.json do
        raise ForbiddenError.new('Access Forbidden')        if @asked_for_index
        render json: @histories 
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
        
        logger.debug("present: #{@resource_history.data}, params: #{params[:data]}, after params eval: #{ params[:data].blank? ? "blank" : eval(params[:data]) }")

        @resource_history.data                  = eval(params[:resource_history][:data])                  unless params[:resource_history][:data].blank?
        @resource_history.localized_description = eval(params[:resource_history][:localized_description]) unless params[:resource_history][:localized_description].blank?
        
        @resource_history.save

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
