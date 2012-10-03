class Resource::SignupGiftsController < ApplicationController
  # GET /resource/signup_gifts
  # GET /resource/signup_gifts.json
  def index
    @resource_signup_gifts = Resource::SignupGift.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_signup_gifts }
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
