class TrackingCallbacksController < ApplicationController
  # GET /tracking_callbacks
  # GET /tracking_callbacks.json
  def index
    @tracking_callbacks = TrackingCallback.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tracking_callbacks }
    end
  end

  # GET /tracking_callbacks/1
  # GET /tracking_callbacks/1.json
  def show
    @tracking_callback = TrackingCallback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tracking_callback }
    end
  end

  # GET /tracking_callbacks/new
  # GET /tracking_callbacks/new.json
  def new
    @tracking_callback = TrackingCallback.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tracking_callback }
    end
  end

  # GET /tracking_callbacks/1/edit
  def edit
    @tracking_callback = TrackingCallback.find(params[:id])
  end

  # POST /tracking_callbacks
  # POST /tracking_callbacks.json
  def create
    @tracking_callback = TrackingCallback.new(params[:tracking_callback])

    respond_to do |format|
      if @tracking_callback.save
        format.html { redirect_to @tracking_callback, notice: 'Tracking callback was successfully created.' }
        format.json { render json: @tracking_callback, status: :created, location: @tracking_callback }
      else
        format.html { render action: "new" }
        format.json { render json: @tracking_callback.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tracking_callbacks/1
  # PUT /tracking_callbacks/1.json
  def update
    @tracking_callback = TrackingCallback.find(params[:id])

    respond_to do |format|
      if @tracking_callback.update_attributes(params[:tracking_callback])
        format.html { redirect_to @tracking_callback, notice: 'Tracking callback was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @tracking_callback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tracking_callbacks/1
  # DELETE /tracking_callbacks/1.json
  def destroy
    @tracking_callback = TrackingCallback.find(params[:id])
    @tracking_callback.destroy

    respond_to do |format|
      format.html { redirect_to tracking_callbacks_url }
      format.json { head :ok }
    end
  end
end
