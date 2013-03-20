class CreateInstallTrackingDevices < ActiveRecord::Migration
  def change
    create_table :install_tracking_devices do |t|
      t.integer :platform_id
      t.string :hardware_string
      t.integer :hardware_id
      t.string :operating_system
      t.string :device_token
      t.boolean :suspicious, :default => false, :null => false
      t.text :note
      t.datetime :banned_at
      t.text :ban_reason
      t.integer :banning_identity_id

      t.timestamps
    end
  end
end
