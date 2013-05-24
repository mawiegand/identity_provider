class CreateInstallTrackingPushNotificationTokens < ActiveRecord::Migration
  def change
    create_table :install_tracking_push_notification_tokens do |t|
      t.string :push_notification_token
      t.string :device_token
      t.string :identifier
      t.string :ip

      t.timestamps
    end
  end
end
