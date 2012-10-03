class ClientNamesController < ApplicationController

  before_filter :authenticate,    :except => [:show]
  before_filter :authorize_staff, :except => [:show]
 
  # GET /client_names
  # GET /client_names.json
  def index
    @client_names = ClientName.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @client_names }
    end
  end

  # GET /client_names/1
  # GET /client_names/1.json
  def show
    @client_name = ClientName.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @client_name }
    end
  end

  # GET /client_names/new
  # GET /client_names/new.json
  def new
    @client_name = ClientName.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @client_name }
    end
  end

  # GET /client_names/1/edit
  def edit
    @client_name = ClientName.find(params[:id])
  end

  # POST /client_names
  # POST /client_names.json
  def create
    @client_name = ClientName.new(params[:client_name])

    respond_to do |format|
      if @client_name.save
        format.html { redirect_to @client_name, notice: 'Client name was successfully created.' }
        format.json { render json: @client_name, status: :created, location: @client_name }
      else
        format.html { render action: "new" }
        format.json { render json: @client_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /client_names/1
  # PUT /client_names/1.json
  def update
    @client_name = ClientName.find(params[:id])

    respond_to do |format|
      if @client_name.update_attributes(params[:client_name])
        format.html { redirect_to @client_name, notice: 'Client name was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @client_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /client_names/1
  # DELETE /client_names/1.json
  def destroy
    @client_name = ClientName.find(params[:id])
    @client_name.destroy

    respond_to do |format|
      format.html { redirect_to client_names_url }
      format.json { head :ok }
    end
  end
end
