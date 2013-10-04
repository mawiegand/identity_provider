class Shop::FbPaymentsLogsController < ApplicationController

  before_filter :authenticate,                    :except => [ :create, :index ]
  before_filter :authorize_staff,                 :except => [ :create, :index ]
  before_filter :deny_api,                        :except => [ :create ]

  FB_VERIFY_TOKEN  = 'UKUKvzHHAg8gjXynx3hioFX7nC8KLa'

  # GET /shop/fb_payments_logs
  # GET /shop/fb_payments_logs.json
  def index
    @shop_fb_payments_logs = Shop::FbPaymentsLog.all

    if !params['hub.verify_token'].blank? && params['hub.verify_token'] == FB_VERIFY_TOKEN
      return_value = params['hub.challenge']
    else
      return_value = "verify_token doesn't match"
    end

    respond_to do |format|
      format.html { render layout: 'raw', text: return_value }
      format.json { render json: @shop_fb_payments_logs }
    end
  end

  # GET /shop/fb_payments_logs/1
  # GET /shop/fb_payments_logs/1.json
  def show
    @shop_fb_payments_log = Shop::FbPaymentsLog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shop_fb_payments_log }
    end
  end

  # GET /shop/fb_payments_logs/new
  # GET /shop/fb_payments_logs/new.json
  def new
    @shop_fb_payments_log = Shop::FbPaymentsLog.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shop_fb_payments_log }
    end
  end

  # GET /shop/fb_payments_logs/1/edit
  def edit
    @shop_fb_payments_log = Shop::FbPaymentsLog.find(params[:id])
  end

  # POST /shop/fb_payments_logs
  # POST /shop/fb_payments_logs.json
  def create
    @shop_fb_payments_log = Shop::FbPaymentsLog.new(params[:shop_fb_payments_log])

    identity = Identity.find_by_fb_player_id(params['user'] && params['user']['id'])

    @shop_fb_payments_log.identity_id = identity.id unless identity.nil?
    @shop_fb_payments_log.payment_id = params['id']
    @shop_fb_payments_log.username = params['user'] && params['user']['name']
    @shop_fb_payments_log.fb_user_id = params['user'] && params['user']['id']
    @shop_fb_payments_log.action_type = params['actions'] && params['actions']['type']
    @shop_fb_payments_log.status = params['actions'] && params['actions']['status']
    @shop_fb_payments_log.currency = params['actions'] && params['actions']['currency']
    @shop_fb_payments_log.amount = params['actions'] && params['actions']['amount']
    @shop_fb_payments_log.time_created = params['actions'] && params['actions']['time_created']
    @shop_fb_payments_log.time_updated = params['actions'] && params['actions']['time_updated']
    @shop_fb_payments_log.product_url = params['items'] && params['items'][0] && params['items'][0]['product']
    @shop_fb_payments_log.quantity = params['items'] && params['items'][0] && params['items'][0]['quantity']
    @shop_fb_payments_log.country = params['country']
    @shop_fb_payments_log.sandbox = params['test']
    @shop_fb_payments_log.fraud_status = params['fraud_status']
    @shop_fb_payments_log.payout_foreign_exchange_rate = params['payout_foreign_exchange_rate']

    respond_to do |format|
      if @shop_fb_payments_log.save
        format.html { redirect_to @shop_fb_payments_log, notice: 'Fb payments log was successfully created.' }
        format.json { render json: @shop_fb_payments_log, status: :created, location: @shop_fb_payments_log }
      else
        format.html { render action: "new" }
        format.json { render json: @shop_fb_payments_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shop/fb_payments_logs/1
  # PUT /shop/fb_payments_logs/1.json
  def update
    @shop_fb_payments_log = Shop::FbPaymentsLog.find(params[:id])

    respond_to do |format|
      if @shop_fb_payments_log.update_attributes(params[:shop_fb_payments_log])
        format.html { redirect_to @shop_fb_payments_log, notice: 'Fb payments log was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @shop_fb_payments_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shop/fb_payments_logs/1
  # DELETE /shop/fb_payments_logs/1.json
  def destroy
    @shop_fb_payments_log = Shop::FbPaymentsLog.find(params[:id])
    @shop_fb_payments_log.destroy

    respond_to do |format|
      format.html { redirect_to shop_fb_payments_logs_url }
      format.json { head :ok }
    end
  end
end
