class ChangeAttributeTypesOfShopFbPaymentsLogs < ActiveRecord::Migration
  def up
    change_column :shop_fb_payments_logs, :fb_user_id, :string
  end

  def down
    change_column :shop_fb_payments_logs, :fb_user_id, :integer
  end
end
