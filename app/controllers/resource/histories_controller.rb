class Resource::HistoriesController < ApplicationController
  # GET /resource/histories
  # GET /resource/histories.json
  def index
    @resource_histories = Resource::History.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_histories }
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
    @resource_history = Resource::History.new(params[:resource_history])

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
