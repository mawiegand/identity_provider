class AddConfirmedAtToInstallTrackingDeviceUser < ActiveRecord::Migration
  def change
    add_column :install_tracking_device_users, :confirmed_at, :datetime
  end
end
