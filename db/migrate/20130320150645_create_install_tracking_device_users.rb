class CreateInstallTrackingDeviceUsers < ActiveRecord::Migration
  def change
    create_table :install_tracking_device_users do |t|
      t.integer :identity_id
      t.integer :device_id
      t.datetime :first_use_at
      t.datetime :last_use_at

      t.timestamps
    end
  end
end
