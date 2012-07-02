class RemoveLimitsFromIdentities < ActiveRecord::Migration
  def up
    change_column :identities, :admin, :boolean
    change_column :identities, :staff, :boolean
  end
  
  def down
    change_column :identities, :admin, :boolean, :limit => 255
    change_column :identities, :staff, :boolean, :limit => 255
  end
end
