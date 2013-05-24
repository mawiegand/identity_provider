class InstallTracking::PushNotificationTokensController < ApplicationController

  before_filter :authenticate,                     :except   => [:create]   # these pages can be seen without logging-in
  before_filter :authorize_staff,                  :except   => [:create]   # only staff can access these pages

  # GET /install_tracking/push_notification_tokens
  # GET /install_tracking/push_notification_tokens.json
  def index
    @install_tracking_push_notification_tokens = InstallTracking::PushNotificationToken.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @install_tracking_push_notification_tokens }
    end
  end

  # GET /install_tracking/push_notification_tokens/1
  # GET /install_tracking/push_notification_tokens/1.json
  def show
    @install_tracking_push_notification_token = InstallTracking::PushNotificationToken.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @install_tracking_push_notification_token }
    end
  end

  # GET /install_tracking/push_notification_tokens/new
  # GET /install_tracking/push_notification_tokens/new.json
  def new
    @install_tracking_push_notification_token = InstallTracking::PushNotificationToken.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @install_tracking_push_notification_token }
    end
  end

  # GET /install_tracking/push_notification_tokens/1/edit
  def edit
    @install_tracking_push_notification_token = InstallTracking::PushNotificationToken.find(params[:id])
  end

  # POST /install_tracking/push_notification_tokens
  # POST /install_tracking/push_notification_tokens.json
  def create
    @install_tracking_push_notification_token = InstallTracking::PushNotificationToken.new(params[:install_tracking_push_notification_token])

    respond_to do |format|
      if @install_tracking_push_notification_token.save
        format.html { redirect_to @install_tracking_push_notification_token, notice: 'Push notification token was successfully created.' }
        format.json { render json: @install_tracking_push_notification_token, status: :created, location: @install_tracking_push_notification_token }
      else
        format.html { render action: "new" }
        format.json { render json: @install_tracking_push_notification_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /install_tracking/push_notification_tokens/1
  # PUT /install_tracking/push_notification_tokens/1.json
  def update
    @install_tracking_push_notification_token = InstallTracking::PushNotificationToken.find(params[:id])

    respond_to do |format|
      if @install_tracking_push_notification_token.update_attributes(params[:install_tracking_push_notification_token])
        format.html { redirect_to @install_tracking_push_notification_token, notice: 'Push notification token was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @install_tracking_push_notification_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /install_tracking/push_notification_tokens/1
  # DELETE /install_tracking/push_notification_tokens/1.json
  def destroy
    @install_tracking_push_notification_token = InstallTracking::PushNotificationToken.find(params[:id])
    @install_tracking_push_notification_token.destroy

    respond_to do |format|
      format.html { redirect_to install_tracking_push_notification_tokens_url }
      format.json { head :ok }
    end
  end
end
