class CreateInstallTrackingInstalls < ActiveRecord::Migration
  def change
    create_table :install_tracking_installs do |t|
      t.integer :release_id
      t.integer :device_id
      t.string :app_token

      t.timestamps
    end
  end
end
