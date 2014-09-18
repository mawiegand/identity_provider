class AddRefIdToInstallTrackingDevice < ActiveRecord::Migration
  def change
    add_column :install_tracking_devices, :ref_id, :string
    add_column :install_tracking_devices, :sub_id, :string
  end
end
