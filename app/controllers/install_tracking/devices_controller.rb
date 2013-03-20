class InstallTracking::DevicesController < ApplicationController
  # GET /install_tracking/devices
  # GET /install_tracking/devices.json
  def index
    @install_tracking_devices = InstallTracking::Device.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @install_tracking_devices }
    end
  end

  # GET /install_tracking/devices/1
  # GET /install_tracking/devices/1.json
  def show
    @install_tracking_device = InstallTracking::Device.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @install_tracking_device }
    end
  end

  # GET /install_tracking/devices/new
  # GET /install_tracking/devices/new.json
  def new
    @install_tracking_device = InstallTracking::Device.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @install_tracking_device }
    end
  end

  # GET /install_tracking/devices/1/edit
  def edit
    @install_tracking_device = InstallTracking::Device.find(params[:id])
  end

  # POST /install_tracking/devices
  # POST /install_tracking/devices.json
  def create
    @install_tracking_device = InstallTracking::Device.new(params[:install_tracking_device])

    respond_to do |format|
      if @install_tracking_device.save
        format.html { redirect_to @install_tracking_device, notice: 'Device was successfully created.' }
        format.json { render json: @install_tracking_device, status: :created, location: @install_tracking_device }
      else
        format.html { render action: "new" }
        format.json { render json: @install_tracking_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /install_tracking/devices/1
  # PUT /install_tracking/devices/1.json
  def update
    @install_tracking_device = InstallTracking::Device.find(params[:id])

    respond_to do |format|
      if @install_tracking_device.update_attributes(params[:install_tracking_device])
        format.html { redirect_to @install_tracking_device, notice: 'Device was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @install_tracking_device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /install_tracking/devices/1
  # DELETE /install_tracking/devices/1.json
  def destroy
    @install_tracking_device = InstallTracking::Device.find(params[:id])
    @install_tracking_device.destroy

    respond_to do |format|
      format.html { redirect_to install_tracking_devices_url }
      format.json { head :ok }
    end
  end
end
