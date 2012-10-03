class Resource::SignupsController < ApplicationController
  # GET /resource/signups
  # GET /resource/signups.json
  def index
    @resource_signups = Resource::Signup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_signups }
    end
  end

  # GET /resource/signups/1
  # GET /resource/signups/1.json
  def show
    @resource_signup = Resource::Signup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_signup }
    end
  end

  # GET /resource/signups/new
  # GET /resource/signups/new.json
  def new
    @resource_signup = Resource::Signup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_signup }
    end
  end

  # GET /resource/signups/1/edit
  def edit
    @resource_signup = Resource::Signup.find(params[:id])
  end

  # POST /resource/signups
  # POST /resource/signups.json
  def create
    @resource_signup = Resource::Signup.new(params[:resource_signup])

    respond_to do |format|
      if @resource_signup.save
        format.html { redirect_to @resource_signup, notice: 'Signup was successfully created.' }
        format.json { render json: @resource_signup, status: :created, location: @resource_signup }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_signup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resource/signups/1
  # PUT /resource/signups/1.json
  def update
    @resource_signup = Resource::Signup.find(params[:id])

    respond_to do |format|
      if @resource_signup.update_attributes(params[:resource_signup])
        format.html { redirect_to @resource_signup, notice: 'Signup was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_signup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource/signups/1
  # DELETE /resource/signups/1.json
  def destroy
    @resource_signup = Resource::Signup.find(params[:id])
    @resource_signup.destroy

    respond_to do |format|
      format.html { redirect_to resource_signups_url }
      format.json { head :ok }
    end
  end
end
