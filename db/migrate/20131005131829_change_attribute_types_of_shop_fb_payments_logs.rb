class ChangeAttributeTypesOfShopFbPaymentsLogs < ActiveRecord::Migration
  def up
    change_column :shop_fb_payments_logs, :fb_user_id, :string
    change_column :shop_fb_payments_logs, :sandbox, :boolean
  end

  def down
    change_column :shop_fb_payments_logs, :fb_user_id, :integer
    change_column :shop_fb_payments_logs, :sandbox, :integer
  end
end
