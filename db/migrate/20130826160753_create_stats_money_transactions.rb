class CreateStatsMoneyTransactions < ActiveRecord::Migration
  def change
    create_table :stats_money_transactions do |t|
      t.integer :identity_id
      t.integer :uid
      t.integer :tstamp
      t.string :updatetstamp
      t.integer :user_id
      t.string :invoice_id
      t.string :title_id
      t.string :method
      t.string :carrier
      t.string :country
      t.integer :offer_id
      t.string :offer_category
      t.decimal :gross
      t.string :gross_currency
      t.decimal :exchange_rate
      t.decimal :vat
      t.decimal :tax
      t.decimal :net
      t.decimal :fee
      t.decimal :ebp
      t.string :referrer_id
      t.decimal :referrer_share
      t.decimal :earnings
      t.decimal :chargeback
      t.string :campaign_id
      t.boolean :transaction_payed
      t.string :transaction_state
      t.string :comment
      t.string :scale_factor
      t.string :user_mail
      t.string :payment_transaction_uid
      t.string :payment_state
      t.string :payment_state_reason
      t.string :payer_id
      t.string :payer_first_name
      t.string :payer_last_name
      t.string :payer_mail
      t.string :payer_zip
      t.string :payer_city
      t.string :payer_street
      t.string :payer_country
      t.string :payer_state
      t.string :hash
      t.string :seed
      t.string :partner_user_id
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean :sent_mail_alert
      t.boolean :sent_special_offer_alert
      t.boolean :recurring

      t.timestamps
    end
  end
end
