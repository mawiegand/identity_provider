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
  scope :completed,      where("transaction_state LIKE 'completed'")
  scope :no_charge_back, where('chargeback < 0.5')
  scope :charge_back,    where('chargeback > 0.5')
  
  before_create :initialize_computed_attributes
  
  private 
  
    def initialize_computed_attributes
        identity = Identity.find_by_identifier(self.partner_user_id)
        if !identity.nil?
          self.recurring   = identity.payments.count > 0
          self.identity_id = identity.id  
        end
    end
  
end
