class Resource::ResultsController < ApplicationController
  

  
  # GET /resource/results
  # GET /resource/results.json
  def index
    @resource_results = Resource::Result.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_results }
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
    @resource_result = Resource::Result.new(params[:resource_result])

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
