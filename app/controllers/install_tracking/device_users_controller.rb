class InstallTracking::DeviceUsersController < ApplicationController
  
  before_filter :authenticate                  

  before_filter :authorize_staff                                    
  before_filter :deny_api
  
  # GET /install_tracking/device_users
  # GET /install_tracking/device_users.json
  def index
    @install_tracking_device_users = InstallTracking::DeviceUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @install_tracking_device_users }
    end
  end

  # GET /install_tracking/device_users/1
  # GET /install_tracking/device_users/1.json
  def show
    @install_tracking_device_user = InstallTracking::DeviceUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @install_tracking_device_user }
    end
  end

  # GET /install_tracking/device_users/new
  # GET /install_tracking/device_users/new.json
  def new
    @install_tracking_device_user = InstallTracking::DeviceUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @install_tracking_device_user }
    end
  end

  # GET /install_tracking/device_users/1/edit
  def edit
    @install_tracking_device_user = InstallTracking::DeviceUser.find(params[:id])
  end

  # POST /install_tracking/device_users
  # POST /install_tracking/device_users.json
  def create
    @install_tracking_device_user = InstallTracking::DeviceUser.new(params[:install_tracking_device_user])

    respond_to do |format|
      if @install_tracking_device_user.save
        format.html { redirect_to @install_tracking_device_user, notice: 'Device user was successfully created.' }
        format.json { render json: @install_tracking_device_user, status: :created, location: @install_tracking_device_user }
      else
        format.html { render action: "new" }
        format.json { render json: @install_tracking_device_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /install_tracking/device_users/1
  # PUT /install_tracking/device_users/1.json
  def update
    @install_tracking_device_user = InstallTracking::DeviceUser.find(params[:id])

    respond_to do |format|
      if @install_tracking_device_user.update_attributes(params[:install_tracking_device_user])
        format.html { redirect_to @install_tracking_device_user, notice: 'Device user was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @install_tracking_device_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /install_tracking/device_users/1
  # DELETE /install_tracking/device_users/1.json
  def destroy
    @install_tracking_device_user = InstallTracking::DeviceUser.find(params[:id])
    @install_tracking_device_user.destroy

    respond_to do |format|
      format.html { redirect_to install_tracking_device_users_url }
      format.json { head :ok }
    end
  end
end
