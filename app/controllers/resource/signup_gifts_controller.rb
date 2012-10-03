class Resource::SignupGiftsController < ApplicationController

  before_filter :authenticate_game_or_backend

  before_filter :authorize_staff,                 :except => [ :index ]                         
  before_filter :deny_api,                        :except => [ :index ]

  # GET /resource/signup_gifts
  # GET /resource/signup_gifts.json
  def index
    
    if params.has_key?(:identity_id)
      # first: filter out bad requests (malformed addresses, black-listed ressources)
      #bad_request = (name_blacklisted?(params[:identity_id]) && !staff?) || !Identity.valid_user_identifier?(params[:identity_id])
      #raise BadRequestError.new('Bad Request for Identity %s' % params[:identity_id]) if bad_request

      # second: find (non-deleted) identity or fail with a 404 not found error
      identity = Identity.find_by_id_identifier_or_nickname(params[:identity_id], :find_deleted => staff?) # only staff can see deleted users
      raise NotFoundError.new('Page Not Found') if identity.nil?    
      if !params.has_key?(:client_id)
        @resource_signup_gifts = identity.signup_gifts
      else
        gift = identity.signup_gifts.where(:client_id => params[:client_id]).first
        logger.debug "Gift: #{gift.inspect}."
        raise NotFoundError.new "No gift found on server for that identity."   if gift.nil?
        @resource_signup_gifts = [gift]
      end
    else 
      @asked_for_index = true
    end

    respond_to do |format|
      format.html do
        if @resource_signup_gifts.nil?
          @resource_signup_gifts =  Resource::SignupGift.paginate(:order => "identity_id ASC", :page => params[:page], :per_page => 50)    
          @paginate = true   
        end 
      end
      format.json do
        raise ForbiddenError.new('Access Forbidden')        if @asked_for_index
        render json: @resource_signup_gifts 
      end
    end    
  end

  # GET /resource/signup_gifts/1
  # GET /resource/signup_gifts/1.json
  def show
    @resource_signup_gift = Resource::SignupGift.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_signup_gift }
    end
  end

  # GET /resource/signup_gifts/new
  # GET /resource/signup_gifts/new.json
  def new
    @resource_signup_gift = Resource::SignupGift.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_signup_gift }
    end
  end

  # GET /resource/signup_gifts/1/edit
  def edit
    @resource_signup_gift = Resource::SignupGift.find(params[:id])
  end

  # POST /resource/signup_gifts
  # POST /resource/signup_gifts.json
  def create
    @resource_signup_gift = Resource::SignupGift.new(params[:resource_signup_gift])

    respond_to do |format|
      if @resource_signup_gift.save
        format.html { redirect_to @resource_signup_gift, notice: 'Signup gift was successfully created.' }
        format.json { render json: @resource_signup_gift, status: :created, location: @resource_signup_gift }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_signup_gift.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resource/signup_gifts/1
  # PUT /resource/signup_gifts/1.json
  def update
    @resource_signup_gift = Resource::SignupGift.find(params[:id])

    respond_to do |format|
      if @resource_signup_gift.update_attributes(params[:resource_signup_gift])
        format.html { redirect_to @resource_signup_gift, notice: 'Signup gift was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_signup_gift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource/signup_gifts/1
  # DELETE /resource/signup_gifts/1.json
  def destroy
    @resource_signup_gift = Resource::SignupGift.find(params[:id])
    @resource_signup_gift.destroy

    respond_to do |format|
      format.html { redirect_to resource_signup_gifts_url }
      format.json { head :ok }
    end
  end
end
