class Shop::FbPaymentsLogsController < ApplicationController

  before_filter :authenticate,          :except => [ :create, :index ]
  before_filter :authorize_staff,       :except => [ :create, :index ]
  before_filter :deny_api,              :except => [ :create, :index ]

  FB_VERIFY_TOKEN  = 'UKUKvzHHAg8gjXynx3hioFX7nC8KLa'
  FB_APP_ID        = '127037377498922'
  FB_APP_SECRET    = 'f88034e6df205b5aa3854e0b92638754'

  # GET /shop/fb_payments_logs
  # GET /shop/fb_payments_logs.json
  def index
    if staff?
      @shop_fb_payments_logs = Shop::FbPaymentsLog.all
    else
      @shop_fb_payments_logs = []
      if !params['hub.verify_token'].blank? && params['hub.verify_token'] == FB_VERIFY_TOKEN
        return_value = params['hub.challenge']
      else
        return_value = "verify_token doesn't match"
      end
    end

    respond_to do |format|
      format.html
      format.json { render text: return_value }
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
    @shop_fb_payments_log = Shop::FbPaymentsLog.new

    logger.debug "---> params: #{params.inspect}"
    payment_id = params['entry'] && params['entry'][0] && params['entry'][0]['id']

    if !payment_id.nil?
      response = HTTParty.get("https://graph.facebook.com/#{payment_id}", :query => {access_token: "#{FB_APP_ID}|#{FB_APP_SECRET}"})

      logger.debug "---> response: #{response.inspect}"

      if response.code == 200

        payment = JSON.parse(response.parsed_response)
        logger.debug "---> payment: #{payment.inspect}"
        fb_user_id = payment['user'] && payment['user']['id']
        identity = Identity.find_by_fb_player_id(fb_user_id)

        @shop_fb_payments_log.identity_id = identity.id unless identity.nil?
        @shop_fb_payments_log.payment_id = payment_id.to_i
        @shop_fb_payments_log.username = payment['user'] && payment['user']['name']
        @shop_fb_payments_log.fb_user_id = fb_user_id
        @shop_fb_payments_log.action_type = payment['actions'] && payment['actions'][0] && payment['actions'][0]['type']
        @shop_fb_payments_log.status = payment['actions'] && payment['actions'][0] && payment['actions'][0]['status']
        @shop_fb_payments_log.currency = payment['actions'] && payment['actions'][0] && payment['actions'][0]['currency']
        @shop_fb_payments_log.amount = payment['actions'] && payment['actions'][0] && payment['actions'][0]['amount']
        @shop_fb_payments_log.time_created = payment['actions'] && payment['actions'][0] && payment['actions'][0]['time_created']
        @shop_fb_payments_log.time_updated = payment['actions'] && payment['actions'][0] && payment['actions'][0]['time_updated']
        @shop_fb_payments_log.product_url = payment['items'] && payment['items'][0] && payment['items'][0]['product']
        @shop_fb_payments_log.quantity = payment['items'] && payment['items'][0] && payment['items'][0]['quantity']
        @shop_fb_payments_log.country = payment['country']
        @shop_fb_payments_log.sandbox = payment['test']
        @shop_fb_payments_log.fraud_status = payment['fraud_status']
        @shop_fb_payments_log.payout_foreign_exchange_rate = payment['payout_foreign_exchange_rate']
      end
    end


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
