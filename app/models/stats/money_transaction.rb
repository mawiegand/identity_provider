require 'five_d'

class Stats::MoneyTransaction < ActiveRecord::Base

  STATES = []
  STATE_CREATED = 1
  STATES[STATE_CREATED] = :created
  STATE_REJECTED = 2
  STATES[STATE_REJECTED] = :rejected
  STATE_CONFIRMED = 3
  STATES[STATE_CONFIRMED] = :confirmed
  STATE_COMMITTED = 4
  STATES[STATE_COMMITTED] = :committed
  STATE_CLOSED = 5
  STATES[STATE_CLOSED] = :closed
  STATE_ABORTED = 6
  STATES[STATE_ABORTED] = :aborted
  STATE_ERROR_NO_CONNECTION = 7
  STATES[STATE_ERROR_NO_CONNECTION] = :error_no_connection
  STATE_ERROR_NOT_BOOKED = 8
  STATES[STATE_ERROR_NOT_BOOKED] = :error_not_booked
  STATE_BOOKED = 9
  STATES[STATE_BOOKED] = :booked
  STATE_PAID_AND_REDEEMED = 10
  STATES[STATE_PAID_AND_REDEEMED] = :paid_and_redeemed
  STATE_PAID = 11
  STATES[STATE_PAID] = :paid
  STATE_REDEEMED = 12
  STATES[STATE_REDEEMED] = :redeemed

  TYPE_CREDIT = 0
  TYPE_DEBIT = 1
  
  API_RESPONSE_OK = 0
  API_RESPONSE_ERROR = 1
  API_RESPONSE_USER_NOT_FOUND = 2
  
  belongs_to  :identity,  :class_name => "Identity",                :foreign_key => :identity_id,  :inverse_of => :payments
  
  scope :offer,          lambda { |id|   where(offer_id: id) }
  scope :since_date,     lambda { |date| where('updatetstamp >= ?', date) }
  scope :completed,      where("transaction_state LIKE 'completed' OR (transaction_state LIKE 'invalid' AND payment_state LIKE 'Completed' AND updatetstamp < '2012-12-31')")
  scope :not_charged_back, where('chargeback < 0.5')
  scope :charged_back,     where('chargeback > 0.5')
  scope :sandbox,        where(['sandbox = ?', true])
  scope :non_sandbox,    where(['sandbox = ?', false])
  
  scope :payment_booking,        where('earnings >= 0.0')
  scope :charge_back_booking,    where('earnings <  0.0')
  
  scope :recurring,              where(['recurring = ?', true])
  scope :sorted_by_date,         order('updatetstamp ASC')
  
  before_create :initialize_computed_attributes
  
  before_save   :track_purchase
  before_save   :track_chargeback
  
  def completed?
    return transaction_state == 'completed'
  end

  def chargeback?
    return (chargeback || 0) >= 0.5
  end
  
  # total gross excluding charged-back transactions, 
  # not considering costs for charge backs
  def self.total_gross
    Stats::MoneyTransaction.non_sandbox.completed.payment_booking.not_charged_back.sum(:gross)
  end

  def self.fraction_recurring
    Stats::MoneyTransaction.non_sandbox.completed.payment_booking.not_charged_back.recurring.count.to_f / Stats::MoneyTransaction.non_sandbox.completed.payment_booking.not_charged_back.count
  end

  # total earning not considering costs for charge backs
  def self.total_earnings
    Stats::MoneyTransaction.non_sandbox.completed.payment_booking.not_charged_back.sum(:earnings)
  end

  # total net earnings, deducing costs for charge backs
  def self.total_net_earnings
    Stats::MoneyTransaction.non_sandbox.completed.sum(:earnings)
  end
  
  def self.total_chargebacks
    Stats::MoneyTransaction.non_sandbox.completed.charge_back_booking.sum(:earnings)
  end
  
  def self.total_sandbox
    Stats::MoneyTransaction.sandbox.completed.sum(:gross)
  end
  
  def track_purchase
    return true   if tracked?
    return true   if chargeback?
    return true   unless completed?
    return true   if sandbox?

    tracker = FiveD::EventTracker.new

    tracker.track('purchase', 'revenue', {
      user_id:                self.partner_user_id || nil,
      pur_provider:           self.carrier,
      pur_gross:              self.gross,
      pur_currency:           self.gross_currency,
      pur_country_code:       self.country,
      pur_earnings:           self.earnings,
      pur_product_sku:        self.offer_id,
      pur_product_category:   self.offer_category,
      invoice_id:             self.invoice_id,
      pur_receipt_identifier: self.payment_transaction_uid,
      timestamp:              self.tstamp || DateTime.now
    });

    self.tracked = true

    true
  end

  def track_chargeback
    return true   if chargeback_tracked?
    return true   unless chargeback?
    return true   if sandbox?

    tracker = FiveD::EventTracker.new

    tracker.track('chargeback', 'revenue', {
      user_id:                self.partner_user_id || nil,
      pur_provider:           self.carrier,
      pur_gross:              self.gross,
      pur_currency:           self.gross_currency,
      pur_country_code:       self.country,
      pur_earnings:           self.earnings,
      pur_product_sku:        self.offer_id,
      pur_product_category:   self.offer_category,
      invoice_id:             self.invoice_id,
      pur_receipt_identifier: self.payment_transaction_uid,
      timestamp:              self.tstamp || DateTime.now
    });

    self.chargeback_tracked = true

    true
  end
  
  private 
  
    def initialize_computed_attributes
        identity = Identity.find_by_identifier(self.partner_user_id)
        if !identity.nil?
          self.recurring   = identity.payments.count > 0
          self.identity_id = identity.id  
        end
    end
  
end
