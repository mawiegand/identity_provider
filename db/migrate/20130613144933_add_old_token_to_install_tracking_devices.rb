class AddOldTokenToInstallTrackingDevices < ActiveRecord::Migration
  def change
    add_column :install_tracking_devices, :old_token, :string
  end
end
