class InstallTracking::InstallsController < ApplicationController
  
  before_filter :authenticate                  

  before_filter :authorize_staff                                    
  before_filter :deny_api
  
  # GET /install_tracking/installs
  # GET /install_tracking/installs.json
  def index
    @install_tracking_installs = InstallTracking::Install.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @install_tracking_installs }
    end
  end

  # GET /install_tracking/installs/1
  # GET /install_tracking/installs/1.json
  def show
    @install_tracking_install = InstallTracking::Install.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @install_tracking_install }
    end
  end

  # GET /install_tracking/installs/new
  # GET /install_tracking/installs/new.json
  def new
    @install_tracking_install = InstallTracking::Install.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @install_tracking_install }
    end
  end

  # GET /install_tracking/installs/1/edit
  def edit
    @install_tracking_install = InstallTracking::Install.find(params[:id])
  end

  # POST /install_tracking/installs
  # POST /install_tracking/installs.json
  def create
    @install_tracking_install = InstallTracking::Install.new(params[:install_tracking_install])

    respond_to do |format|
      if @install_tracking_install.save
        format.html { redirect_to @install_tracking_install, notice: 'Install was successfully created.' }
        format.json { render json: @install_tracking_install, status: :created, location: @install_tracking_install }
      else
        format.html { render action: "new" }
        format.json { render json: @install_tracking_install.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /install_tracking/installs/1
  # PUT /install_tracking/installs/1.json
  def update
    @install_tracking_install = InstallTracking::Install.find(params[:id])

    respond_to do |format|
      if @install_tracking_install.update_attributes(params[:install_tracking_install])
        format.html { redirect_to @install_tracking_install, notice: 'Install was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @install_tracking_install.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /install_tracking/installs/1
  # DELETE /install_tracking/installs/1.json
  def destroy
    @install_tracking_install = InstallTracking::Install.find(params[:id])
    @install_tracking_install.destroy

    respond_to do |format|
      format.html { redirect_to install_tracking_installs_url }
      format.json { head :ok }
    end
  end
end
