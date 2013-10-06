class CreateShopFbPaymentsLogs < ActiveRecord::Migration
  def change
    create_table :shop_fb_payments_logs do |t|
      t.integer :identity_id
      t.integer :payment_id
      t.string :username
      t.integer :fb_user_id
      t.string :action_type
      t.string :status
      t.string :currency
      t.string :amount
      t.string :time_created
      t.string :time_updated
      t.string :product_url
      t.integer :quantity
      t.string :country
      t.integer :sandbox
      t.string :fraud_status
      t.decimal :payout_foreign_exchange_rate

      t.timestamps
    end
  end
end
