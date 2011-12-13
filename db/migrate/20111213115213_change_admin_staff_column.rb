class ChangeAdminStaffColumn < ActiveRecord::Migration
  def change
    change_column :identities, :admin, :boolean
    change_column :identities, :staff, :boolean
  end
end
