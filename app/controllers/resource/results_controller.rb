class Resource::ResultsController < ApplicationController
  
  before_filter :authenticate_game_or_backend,    :only   => [ :create ]
  before_filter :authenticate,                    :except => [ :index, :create ]

  before_filter :authorize_staff,                 :except => [ :index, :create ]                         
  before_filter :deny_api,                        :except => [ :index, :create ]

  
  # GET /resource/results
  # GET /resource/results.json
  def index
    authenticate if website_request?        # only html requests are authenticated using this method. 
    
    if params.has_key?(:identity_id)
      # first: filter out bad requests (malformed addresses, black-listed ressources)
      #bad_request = (name_blacklisted?(params[:identity_id]) && !staff?) || !Identity.valid_user_identifier?(params[:identity_id])
      #raise BadRequestError.new('Bad Request for Identity %s' % params[:identity_id]) if bad_request

      # second: find (non-deleted) identity or fail with a 404 not found error
      identity = Identity.find_by_id_identifier_or_nickname(params[:identity_id], :find_deleted => staff?) # only staff can see deleted users
      raise NotFoundError.new('Page Not Found') if identity.nil?    
      if current_game.nil?
        @resource_results = identity.results
      else
        @resource_results = identity.results.where(:game_id => current_game.id)
      end
    elsif !params[:game_id].blank?
      @resource_results = identity.results.where(:game_id => params[:game_id])
    else
      @asked_for_index = true
    end

    respond_to do |format|
      format.html do
        if @resource_results.nil?
          @resource_results =  Resource::Result.paginate(:order => "identity_id ASC", :page => params[:page], :per_page => 50)    
          @paginate = true   
        end 
      end
      format.json do
        raise ForbiddenError.new('Access Forbidden')        if @asked_for_index
        render json: @resource_results 
      end
    end    
  end

  # GET /resource/results/1
  # GET /resource/results/1.json
  def show
    @resource_result = Resource::Result.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_result }
    end
  end

  # GET /resource/results/new
  # GET /resource/results/new.json
  def new
    @resource_result = Resource::Result.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_result }
    end
  end

  # GET /resource/results/1/edit
  def edit
    @resource_result = Resource::Result.find(params[:id])
  end

  # POST /resource/results
  # POST /resource/results.json
  def create
    raise BadRequestError.new "Malformed or missing data."   unless params.has_key?(:resource_result)
    
    if params.has_key?(:identity_id)
      @identity = Identity.find_by_id_identifier_or_nickname(params[:identity_id], :find_deleted => staff?) # only staff can see deleted users
    elsif params[:resource_result].has_key?(:identity_id)
      @identity = Identity.find_by_id_identifier_or_nickname(params[:resource_result][:identity_id], :find_deleted => staff?) # only staff can see deleted users
    else
      raise BadRequestError.new "Missing identity id" 
    end
    
    @resource_result = @identity.results.build(params[:resource_result])
    
    if !current_game.nil?
      raise ForbiddenError.new "Access to character in different game forbidden."  if params[:resource_result].has_key?(:game_id) && params[:resource_result][:game_id] != current_game.id
      @resource_result.game_id = current_game.id
    end
    
    raise BadRequestError.new "Game id missing"              if @resource_result.game_id.nil?
    raise BadRequestError.new "Identity id missing"          if @resource_result.identity_id.nil?

    respond_to do |format|
      if @resource_result.save
        format.html { redirect_to @resource_result, notice: 'Result was successfully created.' }
        format.json { render json: @resource_result, status: :created, location: @resource_result }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_result.errors, status: :unprocessable_entity }
      end
    end    
  end

  # PUT /resource/results/1
  # PUT /resource/results/1.json
  def update
    @resource_result = Resource::Result.find(params[:id])

    respond_to do |format|
      if @resource_result.update_attributes(params[:resource_result])
        format.html { redirect_to @resource_result, notice: 'Result was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource/results/1
  # DELETE /resource/results/1.json
  def destroy
    @resource_result = Resource::Result.find(params[:id])
    @resource_result.destroy

    respond_to do |format|
      format.html { redirect_to resource_results_url }
      format.json { head :ok }
    end
  end
end
