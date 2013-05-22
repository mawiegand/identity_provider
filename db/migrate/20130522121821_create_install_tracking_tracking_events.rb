class CreateInstallTrackingTrackingEvents < ActiveRecord::Migration
  def change
    create_table :install_tracking_tracking_events do |t|
      t.string :device_token
      t.string :event_name
      t.string :event_args
      t.string :ip

      t.timestamps
    end
  end
end
