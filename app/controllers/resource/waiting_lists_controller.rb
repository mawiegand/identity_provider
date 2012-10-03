class Resource::WaitingListsController < ApplicationController
  
  before_filter :authenticate                  

  before_filter :authorize_staff                                    
  before_filter :deny_api   
  
  # GET /resource/waiting_lists
  # GET /resource/waiting_lists.json
  def index
    @resource_waiting_lists = Resource::WaitingList.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_waiting_lists }
    end
  end

  # GET /resource/waiting_lists/1
  # GET /resource/waiting_lists/1.json
  def show
    @resource_waiting_list = Resource::WaitingList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_waiting_list }
    end
  end

  # GET /resource/waiting_lists/new
  # GET /resource/waiting_lists/new.json
  def new
    @resource_waiting_list = Resource::WaitingList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_waiting_list }
    end
  end

  # GET /resource/waiting_lists/1/edit
  def edit
    @resource_waiting_list = Resource::WaitingList.find(params[:id])
  end

  # POST /resource/waiting_lists
  # POST /resource/waiting_lists.json
  def create
    @resource_waiting_list = Resource::WaitingList.new(params[:resource_waiting_list])

    respond_to do |format|
      if @resource_waiting_list.save
        format.html { redirect_to @resource_waiting_list, notice: 'Waiting list was successfully created.' }
        format.json { render json: @resource_waiting_list, status: :created, location: @resource_waiting_list }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_waiting_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resource/waiting_lists/1
  # PUT /resource/waiting_lists/1.json
  def update
    @resource_waiting_list = Resource::WaitingList.find(params[:id])

    respond_to do |format|
      if @resource_waiting_list.update_attributes(params[:resource_waiting_list])
        format.html { redirect_to @resource_waiting_list, notice: 'Waiting list was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_waiting_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource/waiting_lists/1
  # DELETE /resource/waiting_lists/1.json
  def destroy
    @resource_waiting_list = Resource::WaitingList.find(params[:id])
    @resource_waiting_list.destroy

    respond_to do |format|
      format.html { redirect_to resource_waiting_lists_url }
      format.json { head :ok }
    end
  end
end
