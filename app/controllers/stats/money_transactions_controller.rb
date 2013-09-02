require 'credit_shop'


class Stats::MoneyTransactionsController < ApplicationController
  # GET /stats/money_transactions
  # GET /stats/money_transactions.json
  
  before_filter :authenticate
  before_filter :authorize_staff
  before_filter :deny_api
  
  def index
    
    if params.has_key?(:update)
      CreditShop::BytroShop.update_money_transactions      
    end
    
    
    @stats_money_transactions = Stats::MoneyTransaction.paginate(:order => 'uid desc', :page => params[:page], :per_page => 50)    
    @paginate = true    
    
    last_transaction = Stats::MoneyTransaction.order('uid desc').first
    
    @last_update = last_transaction.nil? ? '-' : last_transaction.updated_at
    
    @total_gross         = Stats::MoneyTransaction.total_gross 
    @total_earnings      = Stats::MoneyTransaction.total_earnings
    @total_net_earnings  = Stats::MoneyTransaction.total_net_earnings
    @total_chargebacks   = Stats::MoneyTransaction.total_chargebacks
    @total_sandbox       = Stats::MoneyTransaction.total_sandbox
    
    @recurring           = Stats::MoneyTransaction.fraction_recurring

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /stats/money_transactions/1
  # GET /stats/money_transactions/1.json
  def show
    @stats_money_transaction = Stats::MoneyTransaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stats_money_transaction }
    end
  end

  # GET /stats/money_transactions/new
  # GET /stats/money_transactions/new.json
  def new
    @stats_money_transaction = Stats::MoneyTransaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stats_money_transaction }
    end
  end

  # GET /stats/money_transactions/1/edit
  def edit
    @stats_money_transaction = Stats::MoneyTransaction.find(params[:id])
  end

  # POST /stats/money_transactions
  # POST /stats/money_transactions.json
  def create
    @stats_money_transaction = Stats::MoneyTransaction.new(params[:stats_money_transaction])

    respond_to do |format|
      if @stats_money_transaction.save
        format.html { redirect_to @stats_money_transaction, notice: 'Money transaction was successfully created.' }
        format.json { render json: @stats_money_transaction, status: :created, location: @stats_money_transaction }
      else
        format.html { render action: "new" }
        format.json { render json: @stats_money_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stats/money_transactions/1
  # PUT /stats/money_transactions/1.json
  def update
    @stats_money_transaction = Stats::MoneyTransaction.find(params[:id])

    respond_to do |format|
      if @stats_money_transaction.update_attributes(params[:stats_money_transaction])
        format.html { redirect_to @stats_money_transaction, notice: 'Money transaction was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @stats_money_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stats/money_transactions/1
  # DELETE /stats/money_transactions/1.json
  def destroy
    @stats_money_transaction = Stats::MoneyTransaction.find(params[:id])
    @stats_money_transaction.destroy

    respond_to do |format|
      format.html { redirect_to stats_money_transactions_url }
      format.json { head :ok }
    end
  end
end
