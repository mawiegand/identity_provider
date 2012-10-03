class AddKeyIdToResourceSignups < ActiveRecord::Migration
  def change
    add_column :resource_signups, :key_id, :integer
  end
end
