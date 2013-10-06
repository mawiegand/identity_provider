class ChangeAttributeTypes2OfShopFbPaymentsLogs < ActiveRecord::Migration
  def up
    change_column :shop_fb_payments_logs, :payment_id, :string
  end

  def down
    change_column :shop_fb_payments_logs, :payment_id, :integer
  end
end
