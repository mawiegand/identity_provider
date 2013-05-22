class InstallTracking::TrackingEventsController < ApplicationController
  
  before_filter :authenticate,                     :except   => [:create]   # these pages can be seen without logging-in
  before_filter :authorize_staff,                  :except   => [:create]   # only staff can access these pages
  
  # GET /install_tracking/tracking_events
  # GET /install_tracking/tracking_events.json
  def index
    @install_tracking_tracking_events = InstallTracking::TrackingEvent.descending

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @install_tracking_tracking_events }
    end
  end

  # GET /install_tracking/tracking_events/1
  # GET /install_tracking/tracking_events/1.json
  def show
    @install_tracking_tracking_event = InstallTracking::TrackingEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @install_tracking_tracking_event }
    end
  end

  # GET /install_tracking/tracking_events/new
  # GET /install_tracking/tracking_events/new.json
  def new
    @install_tracking_tracking_event = InstallTracking::TrackingEvent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @install_tracking_tracking_event }
    end
  end

  # GET /install_tracking/tracking_events/1/edit
  def edit
    @install_tracking_tracking_event = InstallTracking::TrackingEvent.find(params[:id])
  end

  # POST /install_tracking/tracking_events
  # POST /install_tracking/tracking_events.json
  def create
    @install_tracking_tracking_event = InstallTracking::TrackingEvent.new(params[:install_tracking_tracking_event])
    @install_tracking_tracking_event.ip = request.env['REMOTE_ADDR']
    
    respond_to do |format|
      if @install_tracking_tracking_event.save
        format.html { redirect_to @install_tracking_tracking_event, notice: 'Tracking event was successfully created.' }
        format.json { render json: @install_tracking_tracking_event, status: :created, location: @install_tracking_tracking_event }
      else
        format.html { render action: "new" }
        format.json { render json: @install_tracking_tracking_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /install_tracking/tracking_events/1
  # PUT /install_tracking/tracking_events/1.json
  def update
    @install_tracking_tracking_event = InstallTracking::TrackingEvent.find(params[:id])

    respond_to do |format|
      if @install_tracking_tracking_event.update_attributes(params[:install_tracking_tracking_event])
        format.html { redirect_to @install_tracking_tracking_event, notice: 'Tracking event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @install_tracking_tracking_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /install_tracking/tracking_events/1
  # DELETE /install_tracking/tracking_events/1.json
  def destroy
    @install_tracking_tracking_event = InstallTracking::TrackingEvent.find(params[:id])
    @install_tracking_tracking_event.destroy

    respond_to do |format|
      format.html { redirect_to install_tracking_tracking_events_url }
      format.json { head :ok }
    end
  end
end
