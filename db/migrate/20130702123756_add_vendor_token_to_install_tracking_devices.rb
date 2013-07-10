class AddVendorTokenToInstallTrackingDevices < ActiveRecord::Migration
  def change
    add_column :install_tracking_devices, :vendor_token, :string
    add_column :install_tracking_devices, :advertiser_token, :string
    add_column :install_tracking_devices, :hardware_token, :string
  end
end
