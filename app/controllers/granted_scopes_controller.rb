class GrantedScopesController < ApplicationController

  before_filter :authenticate    
  before_filter :authorize_staff
  
  # GET /granted_scopes
  # GET /granted_scopes.json
  def index
    @granted_scopes = GrantedScope.paginate(:page => params[:page], :per_page => 100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @granted_scopes }
    end
  end

  # GET /granted_scopes/1
  # GET /granted_scopes/1.json
  def show
    @granted_scope = GrantedScope.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @granted_scope }
    end
  end

  # GET /granted_scopes/new
  # GET /granted_scopes/new.json
  def new
    @granted_scope = GrantedScope.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @granted_scope }
    end
  end

  # GET /granted_scopes/1/edit
  def edit
    @granted_scope = GrantedScope.find(params[:id])
  end

  # POST /granted_scopes
  # POST /granted_scopes.json
  def create
    @granted_scope = GrantedScope.new(params[:granted_scope])

    respond_to do |format|
      if @granted_scope.save
        format.html { redirect_to @granted_scope, notice: 'Granted scope was successfully created.' }
        format.json { render json: @granted_scope, status: :created, location: @granted_scope }
      else
        format.html { render action: "new" }
        format.json { render json: @granted_scope.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /granted_scopes/1
  # PUT /granted_scopes/1.json
  def update
    @granted_scope = GrantedScope.find(params[:id])

    respond_to do |format|
      if @granted_scope.update_attributes(params[:granted_scope])
        format.html { redirect_to @granted_scope, notice: 'Granted scope was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @granted_scope.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /granted_scopes/1
  # DELETE /granted_scopes/1.json
  def destroy
    @granted_scope = GrantedScope.find(params[:id])
    @granted_scope.destroy

    respond_to do |format|
      format.html { redirect_to granted_scopes_url }
      format.json { head :ok }
    end
  end
end
