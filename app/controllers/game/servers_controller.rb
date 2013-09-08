class Game::ServersController < ApplicationController

  before_filter :authenticate                    
  before_filter :authorize_staff   

  # GET /game/servers
  # GET /game/servers.json
  def index
    @game_servers = Game::Server.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @game_servers }
    end
  end

  # GET /game/servers/1
  # GET /game/servers/1.json
  def show
    @game_server = Game::Server.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game_server }
    end
  end

  # GET /game/servers/new
  # GET /game/servers/new.json
  def new
    @game_server = Game::Server.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game_server }
    end
  end

  # GET /game/servers/1/edit
  def edit
    @game_server = Game::Server.find(params[:id])
  end

  # POST /game/servers
  # POST /game/servers.json
  def create
    @game_server = Game::Server.new(params[:game_server])

    respond_to do |format|
      if @game_server.save
        format.html { redirect_to @game_server, notice: 'Server was successfully created.' }
        format.json { render json: @game_server, status: :created, location: @game_server }
      else
        format.html { render action: "new" }
        format.json { render json: @game_server.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /game/servers/1
  # PUT /game/servers/1.json
  def update
    @game_server = Game::Server.find(params[:id])

    respond_to do |format|
      if @game_server.update_attributes(params[:game_server])
        format.html { redirect_to @game_server, notice: 'Server was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @game_server.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game/servers/1
  # DELETE /game/servers/1.json
  def destroy
    @game_server = Game::Server.find(params[:id])
    @game_server.destroy

    respond_to do |format|
      format.html { redirect_to game_servers_url }
      format.json { head :ok }
    end
  end
end
