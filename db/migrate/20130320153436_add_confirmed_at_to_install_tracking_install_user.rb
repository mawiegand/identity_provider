class AddConfirmedAtToInstallTrackingInstallUser < ActiveRecord::Migration
  def change
    add_column :install_tracking_install_users, :confirmed_at, :datetime
  end
end
