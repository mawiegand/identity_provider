class Game::ScheduledServerDowntimesController < ApplicationController

  before_filter :authenticate                    
  before_filter :authorize_staff      

  # GET /game/scheduled_server_downtimes
  # GET /game/scheduled_server_downtimes.json
  def index
    @game_scheduled_server_downtimes = Game::ScheduledServerDowntime.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @game_scheduled_server_downtimes }
    end
  end

  # GET /game/scheduled_server_downtimes/1
  # GET /game/scheduled_server_downtimes/1.json
  def show
    @game_scheduled_server_downtime = Game::ScheduledServerDowntime.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game_scheduled_server_downtime }
    end
  end

  # GET /game/scheduled_server_downtimes/new
  # GET /game/scheduled_server_downtimes/new.json
  def new
    @game_scheduled_server_downtime = Game::ScheduledServerDowntime.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game_scheduled_server_downtime }
    end
  end

  # GET /game/scheduled_server_downtimes/1/edit
  def edit
    @game_scheduled_server_downtime = Game::ScheduledServerDowntime.find(params[:id])
  end

  # POST /game/scheduled_server_downtimes
  # POST /game/scheduled_server_downtimes.json
  def create
    @game_scheduled_server_downtime = Game::ScheduledServerDowntime.new(params[:game_scheduled_server_downtime])

    respond_to do |format|
      if @game_scheduled_server_downtime.save
        format.html { redirect_to @game_scheduled_server_downtime, notice: 'Scheduled server downtime was successfully created.' }
        format.json { render json: @game_scheduled_server_downtime, status: :created, location: @game_scheduled_server_downtime }
      else
        format.html { render action: "new" }
        format.json { render json: @game_scheduled_server_downtime.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /game/scheduled_server_downtimes/1
  # PUT /game/scheduled_server_downtimes/1.json
  def update
    @game_scheduled_server_downtime = Game::ScheduledServerDowntime.find(params[:id])

    respond_to do |format|
      if @game_scheduled_server_downtime.update_attributes(params[:game_scheduled_server_downtime])
        format.html { redirect_to @game_scheduled_server_downtime, notice: 'Scheduled server downtime was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @game_scheduled_server_downtime.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game/scheduled_server_downtimes/1
  # DELETE /game/scheduled_server_downtimes/1.json
  def destroy
    @game_scheduled_server_downtime = Game::ScheduledServerDowntime.find(params[:id])
    @game_scheduled_server_downtime.destroy

    respond_to do |format|
      format.html { redirect_to game_scheduled_server_downtimes_url }
      format.json { head :ok }
    end
  end
end
