class CreateInstallTrackingInstallUsers < ActiveRecord::Migration
  def change
    create_table :install_tracking_install_users do |t|
      t.integer :identity_id
      t.integer :install_id
      t.datetime :last_use_at
      t.datetime :first_use_at
      t.integer :sign_in_count
      t.string :last_ip_address
      t.string :last_latitude
      t.string :last_longitude
      t.datetime :last_postion_at

      t.timestamps
    end
  end
end
