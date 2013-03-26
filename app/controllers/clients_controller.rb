class ClientsController < ApplicationController
 
  before_filter :authenticate,    :except => [:show]
  before_filter :authorize_staff, :except => [:show]
 
  # GET /clients
  def index
    @clients = Client.order('id asc')

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /clients/1
  def show
    @client = Client.find_by_id_or_identifier(params[:id])
    raise NotFoundError.new "Client not found." if @client.nil?
    
    logger.debug @client.request.protocol + @client.request.host
    
    role = :default  
    if params[:client_id]
      accessing_client = Client.find_by_id_or_identifier(params[:client_id])
      raise ForbiddenError.new "Access forbidden. Client id not found." if accessing_client.nil?
      raise ForbiddenError.new "Access forbidden. Wrong credentials."   if params[:client_password].nil? || params[:client_password] != accessing_client.password
      role = :owner if @client.id == accessing_client.id
    else
      role = current_identity ? current_identity.role : :default   # admin or staff
    end

    logger.debug "ROLE: #{role}"        
    raise ForbiddenError.new   "Access forbidden."   unless role == :owner || staff? || admin? # only staff or the owner (same client) may access its data
    
    respond_to do |format|
      format.json { 
        @attributes = @client.sanitized_hash(role)           # only those, that may be read by present user
        render :json => @attributes.delete_if { |k,v| v.blank? } # to compact the return string to non-blank attrs
      }      
      format.html {
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
