class ClientReleasesController < ApplicationController
  # GET /client_releases
  # GET /client_releases.json
  def index
    @client_releases = ClientRelease.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @client_releases }
    end
  end

  # GET /client_releases/1
  # GET /client_releases/1.json
  def show
    @client_release = ClientRelease.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @client_release }
    end
  end

  # GET /client_releases/new
  # GET /client_releases/new.json
  def new
    @client_release = ClientRelease.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @client_release }
    end
  end

  # GET /client_releases/1/edit
  def edit
    @client_release = ClientRelease.find(params[:id])
  end

  # POST /client_releases
  # POST /client_releases.json
  def create
    @client_release = ClientRelease.new(params[:client_release])

    respond_to do |format|
      if @client_release.save
        format.html { redirect_to @client_release, notice: 'Client release was successfully created.' }
        format.json { render json: @client_release, status: :created, location: @client_release }
      else
        format.html { render action: "new" }
        format.json { render json: @client_release.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /client_releases/1
  # PUT /client_releases/1.json
  def update
    @client_release = ClientRelease.find(params[:id])

    respond_to do |format|
      if @client_release.update_attributes(params[:client_release])
        format.html { redirect_to @client_release, notice: 'Client release was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @client_release.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /client_releases/1
  # DELETE /client_releases/1.json
  def destroy
    @client_release = ClientRelease.find(params[:id])
    @client_release.destroy

    respond_to do |format|
      format.html { redirect_to client_releases_url }
      format.json { head :ok }
    end
  end
end
