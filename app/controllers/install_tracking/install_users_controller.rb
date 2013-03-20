class InstallTracking::InstallUsersController < ApplicationController
  # GET /install_tracking/install_users
  # GET /install_tracking/install_users.json
  def index
    @install_tracking_install_users = InstallTracking::InstallUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @install_tracking_install_users }
    end
  end

  # GET /install_tracking/install_users/1
  # GET /install_tracking/install_users/1.json
  def show
    @install_tracking_install_user = InstallTracking::InstallUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @install_tracking_install_user }
    end
  end

  # GET /install_tracking/install_users/new
  # GET /install_tracking/install_users/new.json
  def new
    @install_tracking_install_user = InstallTracking::InstallUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @install_tracking_install_user }
    end
  end

  # GET /install_tracking/install_users/1/edit
  def edit
    @install_tracking_install_user = InstallTracking::InstallUser.find(params[:id])
  end

  # POST /install_tracking/install_users
  # POST /install_tracking/install_users.json
  def create
    @install_tracking_install_user = InstallTracking::InstallUser.new(params[:install_tracking_install_user])

    respond_to do |format|
      if @install_tracking_install_user.save
        format.html { redirect_to @install_tracking_install_user, notice: 'Install user was successfully created.' }
        format.json { render json: @install_tracking_install_user, status: :created, location: @install_tracking_install_user }
      else
        format.html { render action: "new" }
        format.json { render json: @install_tracking_install_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /install_tracking/install_users/1
  # PUT /install_tracking/install_users/1.json
  def update
    @install_tracking_install_user = InstallTracking::InstallUser.find(params[:id])

    respond_to do |format|
      if @install_tracking_install_user.update_attributes(params[:install_tracking_install_user])
        format.html { redirect_to @install_tracking_install_user, notice: 'Install user was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @install_tracking_install_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /install_tracking/install_users/1
  # DELETE /install_tracking/install_users/1.json
  def destroy
    @install_tracking_install_user = InstallTracking::InstallUser.find(params[:id])
    @install_tracking_install_user.destroy

    respond_to do |format|
      format.html { redirect_to install_tracking_install_users_url }
      format.json { head :ok }
    end
  end
end
