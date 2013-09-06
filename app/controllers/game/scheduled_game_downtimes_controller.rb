class Game::ScheduledGameDowntimesController < ApplicationController
  # GET /game/scheduled_game_downtimes
  # GET /game/scheduled_game_downtimes.json
  def index
    @game_scheduled_game_downtimes = Game::ScheduledGameDowntime.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @game_scheduled_game_downtimes }
    end
  end

  # GET /game/scheduled_game_downtimes/1
  # GET /game/scheduled_game_downtimes/1.json
  def show
    @game_scheduled_game_downtime = Game::ScheduledGameDowntime.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game_scheduled_game_downtime }
    end
  end

  # GET /game/scheduled_game_downtimes/new
  # GET /game/scheduled_game_downtimes/new.json
  def new
    @game_scheduled_game_downtime = Game::ScheduledGameDowntime.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game_scheduled_game_downtime }
    end
  end

  # GET /game/scheduled_game_downtimes/1/edit
  def edit
    @game_scheduled_game_downtime = Game::ScheduledGameDowntime.find(params[:id])
  end

  # POST /game/scheduled_game_downtimes
  # POST /game/scheduled_game_downtimes.json
  def create
    @game_scheduled_game_downtime = Game::ScheduledGameDowntime.new(params[:game_scheduled_game_downtime])

    respond_to do |format|
      if @game_scheduled_game_downtime.save
        format.html { redirect_to @game_scheduled_game_downtime, notice: 'Scheduled game downtime was successfully created.' }
        format.json { render json: @game_scheduled_game_downtime, status: :created, location: @game_scheduled_game_downtime }
      else
        format.html { render action: "new" }
        format.json { render json: @game_scheduled_game_downtime.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /game/scheduled_game_downtimes/1
  # PUT /game/scheduled_game_downtimes/1.json
  def update
    @game_scheduled_game_downtime = Game::ScheduledGameDowntime.find(params[:id])

    respond_to do |format|
      if @game_scheduled_game_downtime.update_attributes(params[:game_scheduled_game_downtime])
        format.html { redirect_to @game_scheduled_game_downtime, notice: 'Scheduled game downtime was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @game_scheduled_game_downtime.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game/scheduled_game_downtimes/1
  # DELETE /game/scheduled_game_downtimes/1.json
  def destroy
    @game_scheduled_game_downtime = Game::ScheduledGameDowntime.find(params[:id])
    @game_scheduled_game_downtime.destroy

    respond_to do |format|
      format.html { redirect_to game_scheduled_game_downtimes_url }
      format.json { head :ok }
    end
  end
end
