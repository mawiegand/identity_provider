class AddStaffToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :staff, :boolean
  end
end
