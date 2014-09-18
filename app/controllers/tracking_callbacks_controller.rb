class TrackingCallbacksController < ApplicationController
  before_filter :authenticate,    :except   => [:track, :create]   # these pages can be seen without logging-in
  before_filter :authorize_staff, :except   => [:track, :create]   # only staff can access these pages

  # GET /tracking_callbacks
  # GET /tracking_callbacks.json
  def index
    @tracking_callbacks = TrackingCallback.descending

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tracking_callbacks }
    end
  end
  
  def track
    @tracking_callback = TrackingCallback.new({
      service:      'adjust',    # presently no other service
      remote_ip:    request.remote_ip,
      http_request: "#{request.protocol}#{request.host_with_port}#{request.fullpath}",
      device_id:    params[:device_id] || params[:deviceid],
      refid:        params[:refid] || params[:ref_id],
      subid:        params[:subid] || params[:sub_id],
    })
    
    respond_to do |format|
      if @tracking_callback.save
        format.html { render text: "OK", status: :created }
        format.json { render json: {},   status: :created }
      else
        format.html { render text: "FAILED", status: :unprocessable_entity }
        format.json { render json: @tracking_callback.errors, status: :unprocessable_entity }
      end  
    end
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
