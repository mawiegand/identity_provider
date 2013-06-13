class AddOldTokenToInstallTrackingTrackingEvent < ActiveRecord::Migration
  def change
    add_column :install_tracking_tracking_events, :old_token, :string
  end
end
