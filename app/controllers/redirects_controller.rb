require 'uri'

class RedirectsController < ApplicationController
  
  layout :determine_layout
  
  before_filter :authenticate,    :except => [:redirect]
  before_filter :authorize_staff, :except => [:redirect]
  
  def redirect
    @title  = "External Redirect"
    @target = params[:url]  if !params[:url].blank? && IDENTITY_PROVIDER_CONFIG['redirect_whitelist'].include?(URI.parse(params[:url]).host.downcase)
    
    if @target.blank?
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  # GET /redirects
  # GET /redirects.json
  def index
    @redirects = Redirect.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @redirects }
    end
  end

  # GET /redirects/1
  # GET /redirects/1.json
  def show
    @redirect = Redirect.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @redirect }
    end
  end

  # GET /redirects/new
  # GET /redirects/new.json
  def new
    @redirect = Redirect.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @redirect }
    end
  end

  # GET /redirects/1/edit
  def edit
    @redirect = Redirect.find(params[:id])
  end

  # POST /redirects
  # POST /redirects.json
  def create
    @redirect = Redirect.new(params[:redirect])

    respond_to do |format|
      if @redirect.save
        format.html { redirect_to @redirect, notice: 'Redirect was successfully created.' }
        format.json { render json: @redirect, status: :created, location: @redirect }
      else
        format.html { render action: "new" }
        format.json { render json: @redirect.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /redirects/1
  # PUT /redirects/1.json
  def update
    @redirect = Redirect.find(params[:id])

    respond_to do |format|
      if @redirect.update_attributes(params[:redirect])
        format.html { redirect_to @redirect, notice: 'Redirect was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @redirect.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /redirects/1
  # DELETE /redirects/1.json
  def destroy
    @redirect = Redirect.find(params[:id])
    @redirect.destroy

    respond_to do |format|
      format.html { redirect_to redirects_url }
      format.json { head :ok }
    end
  end
  
  private 
  
    def determine_layout
      case action_name
      when "redirect"
        "no_layout"
      else
        "application"
      end
    end
  
end
