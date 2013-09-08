class Game::GameInstancesController < ApplicationController

# before_filter :authenticate                    
  before_filter :authorize_staff,                  :except     => [:index, :show]       # only these pages can be accessed by non-staff 

  # GET /game/game_instances
  # GET /game/game_instances.json
  def index
    @game_game_instances = if admin? || staff?
      Game::GameInstance.all
    else
      if !current_identity.nil? && current_identity.insider?
        Game::GameInstance.available.visible
      else 
        Game::GameInstance.available.visible_to_non_insiders
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json do
        if !current_identity.nil?
          render json: @game_game_instances, :methods => [:random_selected_servers]
        else
          render json: @game_game_instances, :methods => [:random_selected_servers]
        end
      end
    end
  end

  # GET /game/game_instances/1
  # GET /game/game_instances/1.json
  def show
    @game_game_instance = Game::GameInstance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game_game_instance }
    end
  end

  # GET /game/game_instances/new
  # GET /game/game_instances/new.json
  def new
    @game_game_instance = Game::GameInstance.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game_game_instance }
    end
  end

  # GET /game/game_instances/1/edit
  def edit
    @game_game_instance = Game::GameInstance.find(params[:id])
  end

  # POST /game/game_instances
  # POST /game/game_instances.json
  def create
    @game_game_instance = Game::GameInstance.new(params[:game_game_instance])

    respond_to do |format|
      if @game_game_instance.save
        format.html { redirect_to @game_game_instance, notice: 'Game instance was successfully created.' }
        format.json { render json: @game_game_instance, status: :created, location: @game_game_instance }
      else
        format.html { render action: "new" }
        format.json { render json: @game_game_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /game/game_instances/1
  # PUT /game/game_instances/1.json
  def update
    @game_game_instance = Game::GameInstance.find(params[:id])

    respond_to do |format|
      if @game_game_instance.update_attributes(params[:game_game_instance])
        format.html { redirect_to @game_game_instance, notice: 'Game instance was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @game_game_instance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game/game_instances/1
  # DELETE /game/game_instances/1.json
  def destroy
    @game_game_instance = Game::GameInstance.find(params[:id])
    @game_game_instance.destroy

    respond_to do |format|
      format.html { redirect_to game_game_instances_url }
      format.json { head :ok }
    end
  end
end
