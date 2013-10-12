class AddIndexToIdentity < ActiveRecord::Migration
  def change
    add_index :identities,  :identifier, unique: true
    add_index :log_entries, :created_at
    add_index :log_entries, :event_type
    add_index :install_tracking_device_users, :auth_count
  end
end
