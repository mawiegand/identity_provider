class ClientsController < ApplicationController
 
  before_filter :authenticate, :except => :show
  before_filter :authorize_staff, :except => :show
 
  # GET /clients
  def index
    @clients = Client.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /clients/1
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.json { 
        @attributes = @client.sanitized_hash(:default)          
        render :json => @attributes.delete_if { |k,v| v.blank? } # to compact the return string to non-blank attrs
      }      
    end
  end

  # GET /clients/new
  def new
    @client = Client.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /clients/1/edit
  def edit
    @client = Client.find(params[:id])
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(params[:client])

    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: 'Client was successfully created.' }
        format.json { render json: @client, status: :created, location: @client }
      else
        format.html { render action: "new" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /clients/1
  # PUT /clients/1.json
  def update
    @client = Client.find(params[:id])

    respond_to do |format|
      if @client.update_attributes(params[:client])
        format.html { redirect_to @client, notice: 'Client was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client = Client.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.html { redirect_to clients_url }
      format.json { head :ok }
    end
  end
end
