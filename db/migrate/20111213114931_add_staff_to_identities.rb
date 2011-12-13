class AddStaffToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :staff, :string
  end
end
