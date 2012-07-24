class Resource::GamesController < ApplicationController
  # GET /resource/games
  # GET /resource/games.json
  def index
    @resource_games = Resource::Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resource_games }
    end
  end

  # GET /resource/games/1
  # GET /resource/games/1.json
  def show
    @resource_game = Resource::Game.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource_game }
    end
  end

  # GET /resource/games/new
  # GET /resource/games/new.json
  def new
    @resource_game = Resource::Game.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource_game }
    end
  end

  # GET /resource/games/1/edit
  def edit
    @resource_game = Resource::Game.find(params[:id])
  end

  # POST /resource/games
  # POST /resource/games.json
  def create
    @resource_game = Resource::Game.new(params[:resource_game])

    respond_to do |format|
      if @resource_game.save
        format.html { redirect_to @resource_game, notice: 'Game was successfully created.' }
        format.json { render json: @resource_game, status: :created, location: @resource_game }
      else
        format.html { render action: "new" }
        format.json { render json: @resource_game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resource/games/1
  # PUT /resource/games/1.json
  def update
    @resource_game = Resource::Game.find(params[:id])

    respond_to do |format|
      if @resource_game.update_attributes(params[:resource_game])
        format.html { redirect_to @resource_game, notice: 'Game was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource_game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resource/games/1
  # DELETE /resource/games/1.json
  def destroy
    @resource_game = Resource::Game.find(params[:id])
    @resource_game.destroy

    respond_to do |format|
      format.html { redirect_to resource_games_url }
      format.json { head :ok }
    end
  end
end
