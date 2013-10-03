class AddAuthCountToInstallTrackingDeviceUsers < ActiveRecord::Migration
  def change
    add_column :install_tracking_device_users, :auth_count, :integer, default: 0, null: false
  end
end
