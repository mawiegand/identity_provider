class MessagesController < ApplicationController

  before_filter :authenticate_game_or_backend,    :only   => [ :create ]
  before_filter :authenticate,                    :except => [ :create ]

  before_filter :authorize_staff,                 :except => [ :create ]                         
  before_filter :deny_api,                        :except => [ :create ]

  def index
    
    if params.has_key?(:identity_id)
      @identity = Identity.find_by_id_identifier_or_nickname(params[:identity_id], :find_deleted => staff?)
      raise NotFoundError.new('Could not find identity.')    if @identity.nil?
      @messages = @identity.received_messages
    else
      @messages = Message.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
  end

  # POST /messages
  # POST /messages.json
  def create
    values = params[:message]
    
    raise BadRequestError.new('Identity and recipient_id do not match.')  if !params[:identity_id].nil? && params[:identity_id] != params[:message][:recipient_id]
    
    values[:sender_id]    = Identity.find_by_id_identifier_or_nickname(params[:message][:sender_id],                            :find_deleted => true)
    values[:recipient_id] = Identity.find_by_id_identifier_or_nickname(params[:identity_id] || params[:message][:recipient_id], :find_deleted => true)
    
    raise NotFoundError.new('Recipient #{params[:message][:recipient_id]} unknown.')  if values[:recipient_id].blank?
    
    @message = Message.new(values)

    respond_to do |format|
      if @message.save
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
        @message.send_via_email
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :ok }
    end
  end
end
